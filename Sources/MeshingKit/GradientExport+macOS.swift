//
//  GradientExport+macOS.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

#if os(macOS)
import AppKit
import AVFoundation
import CoreImage

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

/// Errors that can occur when saving to disk.
public enum SaveToDiskError: Error, Sendable {
    case userCancelled
    case cgImageCreationFailed
    case imageEncodingFailed(Error)
}

public extension MeshingKit {
    // MARK: - Video Export

    /// Tracks video writing progress.
    private final class VideoWriterState: @unchecked Sendable {
        var frameIndex: Int = 0
        var isFinished: Bool = false
    }

    /// Configuration for AVAssetWriter setup.
    private struct AssetWriterConfig {
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
    private struct VideoExportConfig {
        let outputURL: URL
        let videoSize: CGSize
        let frameRate: Int32
        let fileType: AVFileType
        let duration: TimeInterval
        let snapshot: VideoExportSnapshot
    }

    /// Writes video frames to a file using AVAssetWriter with streaming approach.
    nonisolated private static func writeVideo(
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

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            assetConfig.writerInput.requestMediaDataWhenReady(
                on: DispatchQueue(label: "meshing.video.writer")
            ) {
                let loopConfig = FrameLoopConfig(
                    totalFrames: totalFrames,
                    timePerFrame: timePerFrame,
                    videoSize: config.videoSize,
                    snapshot: config.snapshot
                )

                await Self.writeFrameLoop(
                    config: assetConfig,
                    context: context,
                    frameDuration: frameDuration,
                    state: state,
                    loopConfig: loopConfig,
                    continuation: continuation
                )
            }
        }
    }

    /// Configuration for frame writing loop parameters.
    private struct FrameLoopConfig {
        let totalFrames: Int
        let timePerFrame: Double
        let videoSize: CGSize
        let snapshot: VideoExportSnapshot
    }

    /// Writes frames in a loop, rendering each frame on-demand.
    private nonisolated static func writeFrameLoop(
        config: AssetWriterConfig,
        context: CIContext,
        frameDuration: CMTime,
        state: VideoWriterState,
        loopConfig: FrameLoopConfig,
        continuation: CheckedContinuation<Void, Error>
    ) async {
        guard !state.isFinished else { return }

        while config.writerInput.isReadyForMoreMediaData
            && state.frameIndex < loopConfig.totalFrames {
            let index = state.frameIndex
            let phase = Double(index) * loopConfig.timePerFrame

            // Render frame on MainActor
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
                adaptor: config.adaptor,
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
            config.writerInput.markAsFinished()
            config.assetWriter.finishWriting {
                if let error = config.assetWriter.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    /// Exports an animated mesh gradient as an MP4 video file.
    ///
    /// - Parameters:
    ///   - template: The gradient template to export.
    ///   - size: The video dimensions.
    ///   - duration: The video duration in seconds (default: 5.0).
    ///   - frameRate: The frames per second (default: 30).
    ///   - blurRadius: The blur radius for the gradient (default: 0).
    ///   - showDots: Whether to show dots at control points (default: false).
    ///   - animate: Whether to animate the gradient (default: true).
    ///   - smoothsColors: Whether to smooth colors (default: true).
    /// - Returns: The URL of the exported video file.
    ///
    /// - Throws: A `VideoExportError` if export fails.
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

    // MARK: - Save to Disk

    /// Saves an image to disk using a save panel dialog.
    ///
    /// - Parameters:
    ///   - image: The image to save.
    ///   - fileName: The default file name.
    ///   - format: The export format (default: .png).
    ///   - completion: Called with the result URL or error.
    @MainActor
    static func saveToDisk(
        image: NSImage,
        fileName: String = "gradient",
        format: ExportFormat = .png,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save Gradient Image"
        savePanel.message = "Choose a location to save your gradient image."
        savePanel.nameFieldLabel = "File name:"
        savePanel.nameFieldStringValue = "\(fileName).\(format.fileExtension)"

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else {
                completion(.failure(SaveToDiskError.userCancelled))
                return
            }

            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                completion(.failure(SaveToDiskError.cgImageCreationFailed))
                return
            }

            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)

            guard let fileType = format.fileType,
                  let imageData = bitmapRep.representation(using: fileType, properties: [:]) else {
                completion(.failure(SaveToDiskError.imageEncodingFailed(
                    NSError(domain: "MeshingKit", code: -3)
                )))
                return
            }

            do {
                try imageData.write(to: url)
                completion(.success(url))
            } catch {
                completion(.failure(SaveToDiskError.imageEncodingFailed(error)))
            }
        }
    }

    /// Renders and saves a gradient template to disk.
    ///
    /// - Parameters:
    ///   - template: The gradient template to save.
    ///   - size: The image dimensions.
    ///   - scale: The display scale (default: 1.0).
    ///   - blurRadius: Optional blur radius (default: 0).
    ///   - showDots: Whether to show control point dots (default: false).
    ///   - smoothsColors: Whether to smooth colors (default: true).
    ///   - fileName: The default file name (default: "gradient").
    ///   - format: The export format (default: .png).
    ///   - completion: Called with the result.
    @MainActor
    static func saveGradientToDisk(
        template: any GradientTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        smoothsColors: Bool = true,
        fileName: String = "gradient",
        format: ExportFormat = .png,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let cornerRadius: CGFloat = showDots ? 0 : 12
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
            .cornerRadius(cornerRadius)
        )
        renderer.scale = scale
        renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)

        guard let nsImage = renderer.nsImage else {
            completion(.failure(SaveToDiskError.imageEncodingFailed(
                NSError(domain: "MeshingKit", code: -1)
            )))
            return
        }

        saveToDisk(image: nsImage, fileName: fileName, format: format, completion: completion)
    }

    /// Saves a predefined template to disk.
    @MainActor
    static func saveGradientToDisk(
        template: PredefinedTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        smoothsColors: Bool = true,
        fileName: String = "gradient",
        format: ExportFormat = .png,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        saveGradientToDisk(
            template: template.baseTemplate,
            size: size,
            scale: scale,
            blurRadius: blurRadius,
            showDots: showDots,
            smoothsColors: smoothsColors,
            fileName: fileName,
            format: format,
            completion: completion
        )
    }
}
#endif
