//
//  GradientVideoExportInternals.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

#if canImport(AVFoundation) && canImport(CoreImage) && (canImport(UIKit) || canImport(AppKit))
import AVFoundation
import CoreImage
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension MeshingKit {
    actor FrameLoopDriver {
        private let assetConfig: AssetWriterConfig
        private let context: CIContext
        private let frameDuration: CMTime
        private let state: VideoWriterState
        private var isWriting = false

        fileprivate static let minimumAverageBitrate = 2_000_000

        init(
            assetConfig: AssetWriterConfig,
            context: CIContext,
            frameDuration: CMTime,
            state: VideoWriterState
        ) {
            self.assetConfig = assetConfig
            self.context = context
            self.frameDuration = frameDuration
            self.state = state
        }

        fileprivate func startWriting(
            loopConfig: FrameLoopConfig,
            continuation: CheckedContinuation<Void, Error>,
            continuationHolder: ContinuationHolder
        ) {
            assetConfig.writerInput.requestMediaDataWhenReady(
                on: DispatchQueue(label: "meshing.video.writer")
            ) {
                Task {
                    await self.writeFrames(
                        loopConfig: loopConfig,
                        continuation: continuation,
                        continuationHolder: continuationHolder
                    )
                }
            }
        }

        private func writeFrames(
            loopConfig: FrameLoopConfig,
            continuation: CheckedContinuation<Void, Error>,
            continuationHolder: ContinuationHolder
        ) async {
            guard !state.isFinished, !isWriting else { return }
            isWriting = true
            defer { isWriting = false }

            while assetConfig.writerInput.isReadyForMoreMediaData
                && state.frameIndex < loopConfig.totalFrames {
                let index = state.frameIndex
                let phase = Double(index) * loopConfig.timePerFrame

                guard let image = await MainActor.run(
                    body: {
                        renderFrame(
                            at: phase,
                            size: loopConfig.viewSize,
                            snapshot: loopConfig.snapshot
                        )
                    }
                ) else {
                    state.isFinished = true
                    continuationHolder.markResumed()
                    continuation.resume(throwing: VideoExportError.frameRenderingFailed)
                    return
                }

                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(index))

                if let error = Self.processFrame(
                    image: image,
                    presentationTime: presentationTime,
                    adaptor: assetConfig.adaptor,
                    context: context,
                    targetSize: loopConfig.outputSize
                ) {
                    state.isFinished = true
                    continuationHolder.markResumed()
                    continuation.resume(throwing: error)
                    return
                }

                state.frameIndex = index + 1
            }

            if state.frameIndex >= loopConfig.totalFrames && !state.isFinished {
                state.isFinished = true
                assetConfig.writerInput.markAsFinished()
                assetConfig.assetWriter.finishWriting {
                    Task {
                        await self.handleFinish(
                            continuation: continuation,
                            continuationHolder: continuationHolder
                        )
                    }
                }
            }
        }

        private func handleFinish(
            continuation: CheckedContinuation<Void, Error>,
            continuationHolder: ContinuationHolder
        ) {
            continuationHolder.markResumed()
            if let error = assetConfig.assetWriter.error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume()
            }
        }

        func cancelWritingAndCleanup(outputURL: URL) {
            guard !state.isFinished else { return }
            state.isFinished = true
            assetConfig.writerInput.markAsFinished()
            assetConfig.assetWriter.cancelWriting()
            try? FileManager.default.removeItem(at: outputURL)
        }

        func cancelWithContinuation(
            outputURL: URL,
            continuation: CheckedContinuation<Void, Error>
        ) {
            guard !state.isFinished else { return }
            state.isFinished = true
            assetConfig.writerInput.markAsFinished()
            assetConfig.assetWriter.cancelWriting()
            try? FileManager.default.removeItem(at: outputURL)
            continuation.resume(throwing: CancellationError())
        }

        private static func processFrame(
            image: PlatformImage,
            presentationTime: CMTime,
            adaptor: AVAssetWriterInputPixelBufferAdaptor,
            context: CIContext,
            targetSize: CGSize
        ) -> VideoExportError? {
            guard let pixelBufferPool = adaptor.pixelBufferPool else {
                return .pixelBufferPoolCreationFailed
            }

            guard let pixelBuffer = Self.pixelBuffer(
                from: image,
                pixelBufferPool: pixelBufferPool,
                context: context,
                targetSize: targetSize
            ) else {
                return .pixelBufferCreationFailed
            }

            if !adaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                return .failedToAppendPixelBuffer
            }

            return nil
        }

        private static func pixelBuffer(
            from image: PlatformImage,
            pixelBufferPool: CVPixelBufferPool,
            context: CIContext,
            targetSize: CGSize
        ) -> CVPixelBuffer? {
            guard let cgImage = Self.cgImage(from: image) else {
                return nil
            }

            var pixelBuffer: CVPixelBuffer?
            CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBuffer)

            guard let buffer = pixelBuffer else {
                return nil
            }

            let ciImage = CIImage(cgImage: cgImage)

            CVPixelBufferLockBaseAddress(buffer, [])
            defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

            let bounds = CGRect(origin: .zero, size: targetSize)
            context.render(ciImage, to: buffer, bounds: bounds, colorSpace: CGColorSpaceCreateDeviceRGB())

            return buffer
        }

        private static func cgImage(from image: PlatformImage) -> CGImage? {
            #if canImport(UIKit)
            return image.cgImage
            #elseif canImport(AppKit)
            return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
            #else
            return nil
            #endif
        }
    }

    @MainActor
    private static func renderFrame(
        at progress: Double,
        size: CGSize,
        snapshot: VideoExportSnapshot
    ) -> PlatformImage? {
        let points = animatedPositions(
            for: progress,
            positions: snapshot.positions,
            animate: snapshot.shouldAnimate
        )

        let frame = MeshGradient(
            width: snapshot.gridSize,
            height: snapshot.gridSize,
            locations: .points(points),
            colors: .colors(snapshot.colors),
            background: snapshot.background,
            smoothsColors: snapshot.smoothsColors
        )
        .frame(width: size.width, height: size.height)
        .blur(radius: snapshot.blurRadius)
        .clipped()
        .cornerRadius(snapshot.showDots ? 0 : 12)

        let renderer = ImageRenderer(content: frame)
        renderer.scale = snapshot.renderScale
        #if canImport(UIKit)
        return renderer.uiImage
        #elseif canImport(AppKit)
        return renderer.nsImage
        #else
        return nil
        #endif
    }

    static func configureAssetWriter(
        outputURL: URL,
        fileType: AVFileType,
        videoSize: CGSize,
        frameRate: Int32
    ) throws -> AssetWriterConfig {
        let pixels = Double(videoSize.width * videoSize.height)
        let bitsPerPixel: Double = 0.2
        let estimatedBitRate = Int(pixels * Double(frameRate) * bitsPerPixel)
        let averageBitRate = max(FrameLoopDriver.minimumAverageBitrate, estimatedBitRate)
        let compressionSettings: [String: Any] = [
            AVVideoAverageBitRateKey: averageBitRate,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            AVVideoExpectedSourceFrameRateKey: Int(frameRate),
            AVVideoMaxKeyFrameIntervalKey: Int(frameRate)
        ]

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(videoSize.width),
            AVVideoHeightKey: Int(videoSize.height),
            AVVideoCompressionPropertiesKey: compressionSettings
        ]

        let assetWriter = try AVAssetWriter(url: outputURL, fileType: fileType)
        let writerInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: videoSettings
        )
        writerInput.expectsMediaDataInRealTime = false

        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferWidthKey as String: Int(videoSize.width),
            kCVPixelBufferHeightKey as String: Int(videoSize.height)
        ]

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: attributes
        )

        guard assetWriter.canAdd(writerInput) else {
            throw VideoExportError.failedToAddInput
        }

        assetWriter.add(writerInput)

        guard assetWriter.startWriting() else {
            throw assetWriter.error ?? VideoExportError.failedToStartWriting
        }

        assetWriter.startSession(atSourceTime: .zero)

        return AssetWriterConfig(
            assetWriter: assetWriter,
            writerInput: writerInput,
            adaptor: adaptor
        )
    }

    /// Writes video frames to a file using AVAssetWriter with streaming approach.
    nonisolated static func writeVideo(
        config: VideoExportConfig
    ) async throws {
        if FileManager.default.fileExists(atPath: config.outputURL.path) {
            try FileManager.default.removeItem(at: config.outputURL)
        }

        let loopDriver = try makeLoopDriver(config: config)
        let loopConfig = makeLoopConfig(config: config)
        let continuationHolder = ContinuationHolder()

        do {
            try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    continuationHolder.set(continuation)

                    Task {
                        await loopDriver.startWriting(
                            loopConfig: loopConfig,
                            continuation: continuation,
                            continuationHolder: continuationHolder
                        )
                    }
                }
            } onCancel: {
                continuationHolder.resumeWithCancellation()
                Task {
                    await loopDriver.cancelWritingAndCleanup(outputURL: config.outputURL)
                }
            }
        } catch {
            await loopDriver.cancelWritingAndCleanup(outputURL: config.outputURL)
            throw error
        }
    }
}
#endif
