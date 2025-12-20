//
//  GradientExport+iOS.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

#if os(iOS)
import AVFoundation
import CoreImage
import Photos
import UIKit

public extension MeshingKit {
    // MARK: - Save to Photo Library

    /// Saves an image to the user's photo library.
    ///
    /// - Parameters:
    ///   - image: The image to save.
    ///   - completion: A completion handler called with the result.
    static func saveToPhotoAlbum(
        image: UIImage,
        completion: @escaping @Sendable (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                let status = await PHPhotoLibrary.requestAuthorization(
                    for: .addOnly
                )

                guard status == .authorized else {
                    completion(.failure(PhotoLibraryError.permissionDenied))
                    return
                }

                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }

                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Errors that can occur when saving to the photo library.
    public enum PhotoLibraryError: Error, Sendable {
        case permissionDenied
        case saveFailed(Error)
    }

    /// Renders and saves a gradient template to the photo library.
    ///
    /// - Parameters:
    ///   - template: The gradient template to save.
    ///   - size: The image dimensions.
    ///   - scale: The display scale (default: 1.0).
    ///   - blurRadius: Optional blur radius (default: 0).
    ///   - showDots: Whether to show control point dots (default: false).
    ///   - smoothsColors: Whether to smooth colors (default: true).
    ///   - completion: Called with the result.
    @MainActor
    static func saveGradientToPhotoAlbum(
        template: any GradientTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        smoothsColors: Bool = true,
        completion: @escaping @Sendable (Result<Void, Error>) -> Void
    ) {
        let renderer = ImageRenderer(
            content: MeshGradient(
                width: template.size,
                height: template.size,
                locations: .points(template.points),
                colors: .colors(template.colors),
                background: template.background,
                smoothsColors: smoothsColors
            )
            .blur(radius: blurRadius)
            .frame(width: size.width, height: size.height)
            .cornerRadius(showDots ? 0 : 12)
        )
        renderer.scale = scale
        renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)

        guard let uiImage = renderer.uiImage else {
            let error = PhotoLibraryError.saveFailed(NSError(
                domain: "MeshingKit",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to render image"]
            ))
            completion(.failure(error))
            return
        }

        saveToPhotoAlbum(image: uiImage, completion: completion)
    }

    /// Saves a predefined template to the photo library.
    @MainActor
    static func saveGradientToPhotoAlbum(
        template: PredefinedTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        smoothsColors: Bool = true,
        completion: @escaping @Sendable (Result<Void, Error>) -> Void
    ) {
        saveGradientToPhotoAlbum(
            template: template.baseTemplate,
            size: size,
            scale: scale,
            blurRadius: blurRadius,
            showDots: showDots,
            smoothsColors: smoothsColors,
            completion: completion
        )
    }

    /// Exports a gradient as a video and saves it to the photo library.
    ///
    /// - Parameters:
    ///   - template: The gradient template to export.
    ///   - size: The video dimensions.
    ///   - duration: Video duration in seconds (default: 5.0).
    ///   - frameRate: Frames per second (default: 30).
    ///   - blurRadius: Blur radius (default: 0).
    ///   - showDots: Whether to show dots (default: false).
    ///   - animate: Whether to animate (default: true).
    ///   - smoothsColors: Whether to smooth colors (default: true).
    ///   - completion: Called with the result containing a temporary file URL.
    ///     The caller is responsible for deleting this file after use.
    static func exportVideoToPhotoLibrary(
        template: any GradientTemplate,
        size: CGSize,
        duration: TimeInterval = 5.0,
        frameRate: Int32 = 30,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        animate: Bool = true,
        smoothsColors: Bool = true,
        completion: @escaping @Sendable (Result<URL, Error>) -> Void
    ) {
        Task {
            do {
                let videoURL = try await exportVideo(
                    template: template,
                    size: size,
                    duration: duration,
                    frameRate: frameRate,
                    blurRadius: blurRadius,
                    showDots: showDots,
                    animate: animate,
                    smoothsColors: smoothsColors
                )

                let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                guard status == .authorized else {
                    completion(.failure(VideoExportError.photosPermissionDenied))
                    try? FileManager.default.removeItem(at: videoURL)
                    return
                }

                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }

                completion(.success(videoURL))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Exports a predefined template as video to photo library.
    ///
    /// - Parameter completion: Called with the result containing a temporary file URL.
    ///   The caller is responsible for deleting this file after use.
    static func exportVideoToPhotoLibrary(
        template: PredefinedTemplate,
        size: CGSize,
        duration: TimeInterval = 5.0,
        frameRate: Int32 = 30,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        animate: Bool = true,
        smoothsColors: Bool = true,
        completion: @escaping @Sendable (Result<URL, Error>) -> Void
    ) {
        exportVideoToPhotoLibrary(
            template: template.baseTemplate,
            size: size,
            duration: duration,
            frameRate: frameRate,
            blurRadius: blurRadius,
            showDots: showDots,
            animate: animate,
            smoothsColors: smoothsColors,
            completion: completion
        )
    }

    // MARK: - Video Export (iOS)

    private struct VideoExportSnapshot {
        let gridSize: Int
        let positions: [SIMD2<Float>]
        let colors: [Color]
        let background: Color
        let smoothsColors: Bool
        let blurRadius: CGFloat
        let showDots: Bool
        let shouldAnimate: Bool
    }

    private final class VideoWriterState {
        var frameIndex: Int = 0
        var isFinished: Bool = false
    }

    private struct AssetWriterConfig {
        let assetWriter: AVAssetWriter
        let writerInput: AVAssetWriterInput
        let adaptor: AVAssetWriterInputPixelBufferAdaptor
    }

    private struct VideoExportConfig {
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

    private actor FrameLoopDriver {
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
            image: UIImage,
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
            from image: UIImage,
            pixelBufferPool: CVPixelBufferPool,
            context: CIContext
        ) -> CVPixelBuffer? {
            guard let cgImage = image.cgImage else {
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
    }

    @MainActor
    private static func renderFrame(
        at progress: Double,
        size: CGSize,
        snapshot: VideoExportSnapshot
    ) -> UIImage? {
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
        return renderer.uiImage
    }

    private static func configureAssetWriter(
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
