//
//  GradientVideoExport.swift
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

/// A snapshot of gradient state for video export.
public struct VideoExportSnapshot: Sendable {
    public let gridSize: Int
    public let positions: [SIMD2<Float>]
    public let colors: [Color]
    public let background: Color
    public let smoothsColors: Bool
    public let blurRadius: CGFloat
    public let showDots: Bool
    public let shouldAnimate: Bool

    public init(
        gridSize: Int,
        positions: [SIMD2<Float>],
        colors: [Color],
        background: Color,
        smoothsColors: Bool,
        blurRadius: CGFloat,
        showDots: Bool,
        shouldAnimate: Bool
    ) {
        self.gridSize = gridSize
        self.positions = positions
        self.colors = colors
        self.background = background
        self.smoothsColors = smoothsColors
        self.blurRadius = blurRadius
        self.showDots = showDots
        self.shouldAnimate = shouldAnimate
    }
}

public extension MeshingKit {
    // MARK: - Video Export

    final class VideoWriterState {
        var frameIndex: Int = 0
        var isFinished: Bool = false
    }

    struct AssetWriterConfig {
        let assetWriter: AVAssetWriter
        let writerInput: AVAssetWriterInput
        let adaptor: AVAssetWriterInputPixelBufferAdaptor
    }

    struct VideoExportConfig {
        let outputURL: URL
        let videoSize: CGSize
        let frameRate: Int32
        let fileType: AVFileType
        let duration: TimeInterval
        let snapshot: VideoExportSnapshot
    }

    private struct FrameLoopConfig {
        let totalFrames: Int
        let timePerFrame: Double
        let videoSize: CGSize
        let snapshot: VideoExportSnapshot
    }

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

                if let error = Self.processFrame(
                    image: image,
                    presentationTime: presentationTime,
                    adaptor: assetConfig.adaptor,
                    context: context
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

        private static func processFrame(
            image: PlatformImage,
            presentationTime: CMTime,
            adaptor: AVAssetWriterInputPixelBufferAdaptor,
            context: CIContext
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

        private static func pixelBuffer(
            from image: PlatformImage,
            pixelBufferPool: CVPixelBufferPool,
            context: CIContext
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

            let bounds = CGRect(origin: .zero, size: image.size)
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
        renderer.scale = 1
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

    /// Writes video frames to a file using AVAssetWriter with streaming approach.
    private nonisolated static func writeVideo(
        config: VideoExportConfig
    ) async throws {
        if FileManager.default.fileExists(atPath: config.outputURL.path) {
            try FileManager.default.removeItem(at: config.outputURL)
        }

        let assetConfig = try configureAssetWriter(
            outputURL: config.outputURL,
            fileType: config.fileType,
            videoSize: config.videoSize
        )

        let frameDuration = CMTimeMake(value: 1, timescale: config.frameRate)
        let context = CIContext(options: [.useSoftwareRenderer: false])

        let totalFrames = max(
            1,
            Int((config.duration * Double(config.frameRate)).rounded(.toNearestOrAwayFromZero))
        )
        let timePerFrame = 1.0 / Double(config.frameRate)

        let state = VideoWriterState()
        let loopDriver = FrameLoopDriver(
            assetConfig: assetConfig,
            context: context,
            frameDuration: frameDuration,
            state: state
        )

        let videoSize = config.videoSize
        let snapshot = config.snapshot

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                await loopDriver.startWriting(
                    totalFrames: totalFrames,
                    timePerFrame: timePerFrame,
                    videoSize: videoSize,
                    snapshot: snapshot,
                    continuation: continuation
                )
            }
        }
    }

    /// Exports an animated mesh gradient as an MP4 video file.
    @MainActor
    static func exportVideo(
        template: any GradientTemplate,
        size: CGSize,
        duration: TimeInterval = 5.0,
        frameRate: Int32 = 30,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        animate: Bool = true,
        smoothsColors: Bool = true
    ) async throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())

        let tempDir = FileManager.default.temporaryDirectory
        let outputURL = tempDir.appendingPathComponent("meshGradient_\(dateString).mp4")

        let snapshot = VideoExportSnapshot(
            gridSize: template.size,
            positions: template.points,
            colors: template.colors,
            background: template.background,
            smoothsColors: smoothsColors,
            blurRadius: blurRadius,
            showDots: showDots,
            shouldAnimate: animate
        )

        let exportTask = Task.detached(priority: .userInitiated) {
            let exportConfig = VideoExportConfig(
                outputURL: outputURL,
                videoSize: size,
                frameRate: frameRate,
                fileType: .mp4,
                duration: duration,
                snapshot: snapshot
            )

            try await Self.writeVideo(config: exportConfig)

            guard FileManager.default.fileExists(atPath: outputURL.path) else {
                throw VideoExportError.fileNotAccessible
            }

            return outputURL
        }

        return try await exportTask.value
    }

    /// Exports a predefined template as an MP4 video.
    @MainActor
    static func exportVideo(
        template: PredefinedTemplate,
        size: CGSize,
        duration: TimeInterval = 5.0,
        frameRate: Int32 = 30,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        animate: Bool = true,
        smoothsColors: Bool = true
    ) async throws -> URL {
        try await exportVideo(
            template: template.baseTemplate,
            size: size,
            duration: duration,
            frameRate: frameRate,
            blurRadius: blurRadius,
            showDots: showDots,
            animate: animate,
            smoothsColors: smoothsColors
        )
    }
}
#endif
