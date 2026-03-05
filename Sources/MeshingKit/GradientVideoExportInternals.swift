//
//  GradientVideoExportInternals.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

#if canImport(AVFoundation) && canImport(CoreImage) && (canImport(UIKit) || canImport(AppKit))
import AVFoundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension MeshingKit {
    actor FrameLoopDriver {
        private let assetConfig: AssetWriterConfig
        private let frameDuration: CMTime
        private let state: VideoWriterState
        private var isWriting = false
        private var cachedStaticFrame: CGImage?

        fileprivate static let minimumAverageBitrate = 2_000_000

        init(
            assetConfig: AssetWriterConfig,
            frameDuration: CMTime,
            state: VideoWriterState
        ) {
            self.assetConfig = assetConfig
            self.frameDuration = frameDuration
            self.state = state
        }

        fileprivate func startWriting(
            loopConfig: FrameLoopConfig,
            continuationHolder: ContinuationHolder
        ) {
            guard !state.isFinished else { return }
            guard assetConfig.assetWriter.status == .writing else {
                state.isFinished = true
                continuationHolder.resume(
                    throwing: assetConfig.assetWriter.error ?? VideoExportError.failedToStartWriting
                )
                return
            }

            assetConfig.writerInput.requestMediaDataWhenReady(
                on: DispatchQueue(label: "meshing.video.writer")
            ) {
                Task {
                    await self.writeFrames(
                        loopConfig: loopConfig,
                        continuationHolder: continuationHolder
                    )
                }
            }
        }

        private func writeFrames(
            loopConfig: FrameLoopConfig,
            continuationHolder: ContinuationHolder
        ) async {
            guard !state.isFinished, !isWriting else { return }
            isWriting = true
            defer { isWriting = false }

            while assetConfig.writerInput.isReadyForMoreMediaData
                && state.frameIndex < loopConfig.totalFrames {
                let index = state.frameIndex
                let frameImage: CGImage

                if loopConfig.snapshot.shouldAnimate {
                    let points = loopConfig.points(forFrame: index)
                    guard let renderedFrame = await MainActor.run(
                        body: {
                            renderFrame(
                                points: points,
                                size: loopConfig.viewSize,
                                snapshot: loopConfig.snapshot
                            )
                        }
                    ) else {
                        state.isFinished = true
                        continuationHolder.resume(throwing: VideoExportError.frameRenderingFailed)
                        return
                    }
                    frameImage = renderedFrame
                } else {
                    if cachedStaticFrame == nil {
                        cachedStaticFrame = await MainActor.run(
                            body: {
                                renderFrame(
                                    points: loopConfig.snapshot.positions,
                                    size: loopConfig.viewSize,
                                    snapshot: loopConfig.snapshot
                                )
                            }
                        )
                    }

                    guard let staticFrame = cachedStaticFrame else {
                        state.isFinished = true
                        continuationHolder.resume(throwing: VideoExportError.frameRenderingFailed)
                        return
                    }
                    frameImage = staticFrame
                }

                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(index))

                if let error = Self.processFrame(
                    cgImage: frameImage,
                    presentationTime: presentationTime,
                    adaptor: assetConfig.adaptor,
                    targetSize: loopConfig.outputSize
                ) {
                    state.isFinished = true
                    continuationHolder.resume(throwing: error)
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
                            continuationHolder: continuationHolder
                        )
                    }
                }
            }
        }

        private func handleFinish(
            continuationHolder: ContinuationHolder
        ) {
            if let error = assetConfig.assetWriter.error {
                continuationHolder.resume(throwing: error)
            } else {
                continuationHolder.resume()
            }
        }

        func cancelWritingAndCleanup(outputURL: URL) {
            guard !state.isFinished else { return }
            state.isFinished = true
            assetConfig.writerInput.markAsFinished()
            assetConfig.assetWriter.cancelWriting()
            try? FileManager.default.removeItem(at: outputURL)
        }

        private static func processFrame(
            cgImage: CGImage,
            presentationTime: CMTime,
            adaptor: AVAssetWriterInputPixelBufferAdaptor,
            targetSize: CGSize
        ) -> VideoExportError? {
            guard let pixelBufferPool = adaptor.pixelBufferPool else {
                return .pixelBufferPoolCreationFailed
            }

            guard let pixelBuffer = Self.pixelBuffer(
                from: cgImage,
                pixelBufferPool: pixelBufferPool,
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
            from cgImage: CGImage,
            pixelBufferPool: CVPixelBufferPool,
            targetSize: CGSize
        ) -> CVPixelBuffer? {
            var pixelBuffer: CVPixelBuffer?
            CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBuffer)

            guard let buffer = pixelBuffer else {
                return nil
            }

            CVPixelBufferLockBaseAddress(buffer, [])
            defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

            guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else {
                return nil
            }

            let width = Int(targetSize.width)
            let height = Int(targetSize.height)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
            let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
                | CGBitmapInfo.byteOrder32Little.rawValue

            guard let context = CGContext(
                data: baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: Self.rgbColorSpace,
                bitmapInfo: bitmapInfo
            ) else {
                return nil
            }

            context.clear(CGRect(x: 0, y: 0, width: width, height: height))
            context.interpolationQuality = .high
            context.translateBy(x: 0, y: CGFloat(height))
            context.scaleBy(x: 1, y: -1)
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

            return buffer
        }

        private static let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    }

    @MainActor
    private static func renderFrame(
        points: [SIMD2<Float>],
        size: CGSize,
        snapshot: VideoExportSnapshot
    ) -> CGImage? {
        let frame = MeshGradient(
            width: snapshot.gridSize,
            height: snapshot.gridSize,
            locations: .points(points),
            colors: .colors(snapshot.colors),
            background: snapshot.background,
            smoothsColors: snapshot.smoothsColors
        )
        .frame(width: size.width, height: size.height)
        .overlay(alignment: .topLeading) {
            if snapshot.showDots {
                MeshingKit.controlPointsOverlay(
                    points: points,
                    colors: snapshot.colors,
                    size: size
                )
            }
        }
        .blur(radius: snapshot.blurRadius)
        .clipped()
        .cornerRadius(snapshot.showDots ? 0 : 12)

        let renderer = ImageRenderer(content: frame)
        renderer.scale = snapshot.renderScale
        renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)
        return renderer.cgImage
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
