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
    public let renderScale: CGFloat

    public init(
        gridSize: Int,
        positions: [SIMD2<Float>],
        colors: [Color],
        background: Color,
        smoothsColors: Bool,
        blurRadius: CGFloat,
        showDots: Bool,
        shouldAnimate: Bool,
        renderScale: CGFloat
    ) {
        self.gridSize = gridSize
        self.positions = positions
        self.colors = colors
        self.background = background
        self.smoothsColors = smoothsColors
        self.blurRadius = blurRadius
        self.showDots = showDots
        self.shouldAnimate = shouldAnimate
        self.renderScale = renderScale
    }
}

/// Configuration for exporting gradient videos.
public struct VideoExportConfiguration: Sendable {
    public var size: CGSize
    public var duration: TimeInterval
    public var frameRate: Int32
    public var blurRadius: CGFloat
    public var showDots: Bool
    public var animate: Bool
    public var smoothsColors: Bool
    public var renderScale: CGFloat

    public init(
        size: CGSize,
        duration: TimeInterval = 5.0,
        frameRate: Int32 = 30,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        animate: Bool = true,
        smoothsColors: Bool = true,
        renderScale: CGFloat = 1.0
    ) {
        self.size = size
        self.duration = duration
        self.frameRate = frameRate
        self.blurRadius = blurRadius
        self.showDots = showDots
        self.animate = animate
        self.smoothsColors = smoothsColors
        self.renderScale = renderScale
    }
}

public extension MeshingKit {
    // MARK: - Video Export

    /// Default timeout for video export operations (30 minutes).
    static let videoExportTimeout: TimeInterval = 30 * 60

    /// Exports an animated mesh gradient as an MP4 video file.
    @MainActor
    static func exportVideo(
        template: any GradientTemplate,
        configuration: VideoExportConfiguration,
        timeout: TimeInterval = videoExportTimeout
    ) async throws -> URL {
        try await exportVideo(
            template: template,
            size: configuration.size,
            duration: configuration.duration,
            frameRate: configuration.frameRate,
            blurRadius: configuration.blurRadius,
            showDots: configuration.showDots,
            animate: configuration.animate,
            smoothsColors: configuration.smoothsColors,
            renderScale: configuration.renderScale,
            timeout: timeout
        )
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
        smoothsColors: Bool = true,
        renderScale: CGFloat = 1.0,
        timeout: TimeInterval = videoExportTimeout
    ) async throws -> URL {
        try validateVideoExportConfiguration(
            template: template,
            size: size,
            duration: duration,
            frameRate: frameRate,
            renderScale: renderScale
        )

        let config = VideoExportConfiguration(
            size: size,
            duration: duration,
            frameRate: frameRate,
            blurRadius: blurRadius,
            showDots: showDots,
            animate: animate,
            smoothsColors: smoothsColors,
            renderScale: renderScale
        )

        let params = buildExportParams(template: template, size: size, config: config, timeout: timeout)
        return try await performVideoExport(params: params)
    }

    // MARK: - Private Helpers

    private struct VideoExportParams {
        let outputURL: URL
        let viewSize: CGSize
        let outputSize: CGSize
        let frameRate: Int32
        let duration: TimeInterval
        let snapshot: VideoExportSnapshot
        let timeout: TimeInterval
    }

    private static func createOutputURL() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        let tempDir = FileManager.default.temporaryDirectory
        let uniqueID = UUID().uuidString
        return tempDir.appendingPathComponent("meshGradient_\(dateString)_\(uniqueID).mp4")
    }

    private static func calculateOutputSize(from size: CGSize, renderScale: CGFloat) -> CGSize {
        let width = max(1, Int((size.width * renderScale).rounded()))
        let height = max(1, Int((size.height * renderScale).rounded()))
        return CGSize(width: width, height: height)
    }

    private static func buildExportParams(
        template: any GradientTemplate,
        size: CGSize,
        config: VideoExportConfiguration,
        timeout: TimeInterval
    ) -> VideoExportParams {
        let snapshot = VideoExportSnapshot(
            gridSize: template.size,
            positions: template.points,
            colors: template.colors,
            background: template.background,
            smoothsColors: config.smoothsColors,
            blurRadius: config.blurRadius,
            showDots: config.showDots,
            shouldAnimate: config.animate,
            renderScale: config.renderScale
        )

        return VideoExportParams(
            outputURL: createOutputURL(),
            viewSize: size,
            outputSize: calculateOutputSize(from: size, renderScale: config.renderScale),
            frameRate: config.frameRate,
            duration: config.duration,
            snapshot: snapshot,
            timeout: timeout
        )
    }

    private static func performVideoExport(params: VideoExportParams) async throws -> URL {
        let outputURLCopy = params.outputURL

        do {
            return try await withThrowingTaskGroup(of: URL.self) { group in
                group.addTask {
                    let exportConfig = VideoExportConfig(
                        outputURL: outputURLCopy,
                        viewSize: params.viewSize,
                        outputSize: params.outputSize,
                        frameRate: params.frameRate,
                        fileType: .mp4,
                        duration: params.duration,
                        snapshot: params.snapshot
                    )

                    try await Self.writeVideo(config: exportConfig)

                    guard FileManager.default.fileExists(atPath: outputURLCopy.path) else {
                        throw VideoExportError.fileNotAccessible
                    }

                    return outputURLCopy
                }

                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(params.timeout * 1_000_000_000))
                    throw VideoExportError.videoExportTimedOut(params.timeout)
                }

                let result = try await group.next()!
                group.cancelAll()
                return result
            }
        } catch {
            try? FileManager.default.removeItem(at: outputURLCopy)
            throw error
        }
    }

    /// Exports a predefined template as an MP4 video.
    @MainActor
    static func exportVideo(
        template: PredefinedTemplate,
        configuration: VideoExportConfiguration,
        timeout: TimeInterval = videoExportTimeout
    ) async throws -> URL {
        try await exportVideo(
            template: template.baseTemplate,
            configuration: configuration,
            timeout: timeout
        )
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
        smoothsColors: Bool = true,
        renderScale: CGFloat = 1.0,
        timeout: TimeInterval = videoExportTimeout
    ) async throws -> URL {
        try await exportVideo(
            template: template.baseTemplate,
            size: size,
            duration: duration,
            frameRate: frameRate,
            blurRadius: blurRadius,
            showDots: showDots,
            animate: animate,
            smoothsColors: smoothsColors,
            renderScale: renderScale,
            timeout: timeout
        )
    }
}

private extension MeshingKit {
    static func validateVideoExportConfiguration(
        template: any GradientTemplate,
        size: CGSize,
        duration: TimeInterval,
        frameRate: Int32,
        renderScale: CGFloat
    ) throws {
        guard validateDuration(duration) else {
            throw VideoExportError.invalidConfiguration(
                duration > 0 ? "Duration must not exceed 1 hour." : "Duration must be greater than 0."
            )
        }

        guard validateFrameRate(frameRate) else {
            throw VideoExportError.invalidConfiguration(
                frameRate > 0 ? "Frame rate must not exceed 120." : "Frame rate must be greater than 0."
            )
        }

        guard validateSize(size) else {
            throw VideoExportError.invalidConfiguration(
                size.width.isFinite && size.height.isFinite
                    ? "Video dimensions must not exceed 8192x8192."
                    : "Video size must be finite and greater than 0."
            )
        }

        guard validateRenderScale(renderScale) else {
            throw VideoExportError.invalidConfiguration(
                renderScale.isFinite && renderScale > 0
                    ? "Render scale must not exceed 4.0."
                    : "Render scale must be finite and greater than 0."
            )
        }

        guard template.size > 0,
              template.points.count == template.size * template.size,
              template.colors.count == template.size * template.size else {
            throw VideoExportError.invalidConfiguration("Invalid template structure.")
        }
    }

    private static func validateDuration(_ duration: TimeInterval) -> Bool {
        duration > 0 && duration <= 3600
    }

    private static func validateFrameRate(_ frameRate: Int32) -> Bool {
        frameRate > 0 && frameRate <= 120
    }

    private static func validateSize(_ size: CGSize) -> Bool {
        let maxDimension = 8192.0
        return size.width.isFinite && size.height.isFinite
            && size.width > 0 && size.height > 0
            && size.width <= maxDimension && size.height <= maxDimension
    }

    private static func validateRenderScale(_ renderScale: CGFloat) -> Bool {
        renderScale.isFinite && renderScale > 0 && renderScale <= 4.0
    }
}
#endif
