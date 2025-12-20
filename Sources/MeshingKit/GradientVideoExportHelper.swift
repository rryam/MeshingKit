//
//  GradientVideoExportHelper.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

#if os(macOS)
import AppKit
import AVFoundation
import CoreImage

public extension MeshingKit {
    /// Tracks video writing progress.
    final class VideoWriterState {
        var frameIndex: Int = 0
        var isFinished: Bool = false
    }

    /// Configuration for AVAssetWriter setup.
    struct AssetWriterConfig {
        let assetWriter: AVAssetWriter
        let writerInput: AVAssetWriterInput
        let adaptor: AVAssetWriterInputPixelBufferAdaptor
    }

    /// Generates all video frames for the given parameters.
    private static func generateFrames(
        duration: TimeInterval,
        frameRate: Int32,
        size: CGSize,
        snapshot: VideoExportSnapshot
    ) async throws -> [NSImage] {
        let totalFrames = max(1, Int((duration * Double(frameRate)).rounded(.toNearestOrAwayFromZero)))
        let timePerFrame = 1.0 / Double(frameRate)

        var images: [NSImage] = []
        for frameIndex in 0..<totalFrames {
            let phase = Double(frameIndex) * timePerFrame
            guard let image = await MainActor.run(
                body: { renderFrame(at: phase, size: size, snapshot: snapshot) }
            ) else {
                throw VideoExportError.frameRenderingFailed
            }
            images.append(image)
        }
        return images
    }

    /// Renders a single video frame at a specific animation phase.
    @MainActor
    private static func renderFrame(
        at progress: Double,
        size: CGSize,
        snapshot: VideoExportSnapshot
    ) -> NSImage? {
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
        renderer.scale = 1
        return renderer.nsImage
    }

    /// Creates a pixel buffer from an NSImage for video encoding.
    nonisolated private static func pixelBuffer(
        from image: NSImage,
        pixelBufferPool: CVPixelBufferPool,
        context: CIContext
    ) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
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

        let bounds = CGRect(origin: .zero, size: image.size)
        context.render(ciImage, to: buffer, bounds: bounds, colorSpace: CGColorSpaceCreateDeviceRGB())

        return buffer
    }

    /// Configures the video asset writer with input and adaptor.
    static func configureAssetWriter(
        outputURL: URL,
        fileType: AVFileType,
        videoSize: CGSize
    ) throws -> AssetWriterConfig {
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(videoSize.width),
            AVVideoHeightKey: Int(videoSize.height)
        ]

        let assetWriter = try AVAssetWriter(url: outputURL, fileType: fileType)
        let writerInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: videoSettings
        )
        writerInput.expectsMediaDataInRealTime = false

        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
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

    /// Processes a single frame and returns an error if it occurred.
    private static func processFrame(
        image: NSImage,
        presentationTime: CMTime,
        adaptor: AVAssetWriterInputPixelBufferAdaptor,
        context: CIContext,
        state: MeshingKit.VideoWriterState
    ) -> VideoExportError? {
        guard let pixelBufferPool = adaptor.pixelBufferPool else {
            return .pixelBufferPoolCreationFailed
        }

        guard let pixelBuffer = Self.pixelBuffer(
            from: image,
            pixelBufferPool: pixelBufferPool,
            context: context
        ) else {
            return .pixelBufferCreationFailed
        }

        if !adaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
            return .failedToAppendPixelBuffer
        }

        return nil
    }

    /// Configuration for video export parameters.
    struct VideoExportConfig {
        let outputURL: URL
        let videoSize: CGSize
        let frameRate: Int32
        let fileType: AVFileType
        let duration: TimeInterval
        let snapshot: VideoExportSnapshot
    }

    /// Configuration for frame writing loop parameters.
    private struct FrameLoopConfig {
        let totalFrames: Int
        let timePerFrame: Double
        let videoSize: CGSize
        let snapshot: VideoExportSnapshot
    }

    /// Serializes frame writing to avoid overlapping loops.
    actor FrameLoopDriver {
        private let assetConfig: AssetWriterConfig
        private let context: CIContext
        private let frameDuration: CMTime
        private let state: VideoWriterState
        private var isWriting = false

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

        func startWriting(
            totalFrames: Int,
            timePerFrame: Double,
            videoSize: CGSize,
            snapshot: VideoExportSnapshot,
            continuation: CheckedContinuation<Void, Error>
        ) {
            let loopConfig = FrameLoopConfig(
                totalFrames: totalFrames,
                timePerFrame: timePerFrame,
                videoSize: videoSize,
                snapshot: snapshot
            )

            assetConfig.writerInput.requestMediaDataWhenReady(
                on: DispatchQueue(label: "meshing.video.writer")
            ) {
                Task {
                    await self.writeFrames(
                        loopConfig: loopConfig,
                        continuation: continuation
                    )
                }
            }
        }

        private func writeFrames(
            loopConfig: FrameLoopConfig,
            continuation: CheckedContinuation<Void, Error>
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
                            size: loopConfig.videoSize,
                            snapshot: loopConfig.snapshot
                        )
                    }
                ) else {
                    state.isFinished = true
                    continuation.resume(throwing: VideoExportError.frameRenderingFailed)
                    return
                }

                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(index))

                if let error = MeshingKit.processFrame(
                    image: image,
                    presentationTime: presentationTime,
                    adaptor: assetConfig.adaptor,
                    context: context,
                    state: state
                ) {
                    state.isFinished = true
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
                        await self.handleFinish(continuation: continuation)
                    }
                }
            }
        }

        private func handleFinish(
            continuation: CheckedContinuation<Void, Error>
        ) {
            if let error = assetConfig.assetWriter.error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume()
            }
        }
    }

}
#endif
