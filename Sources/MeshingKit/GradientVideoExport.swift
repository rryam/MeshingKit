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

public extension MeshingKit {
    // MARK: - Video Export

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
        renderScale: CGFloat = 1.0
    ) async throws -> URL {
        try validateVideoExportConfiguration(
            template: template,
            size: size,
            duration: duration,
            frameRate: frameRate,
            renderScale: renderScale
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())

        let tempDir = FileManager.default.temporaryDirectory
        let uniqueID = UUID().uuidString
        let outputURL = tempDir.appendingPathComponent("meshGradient_\(dateString)_\(uniqueID).mp4")

        let outputWidth = max(1, Int((size.width * renderScale).rounded()))
        let outputHeight = max(1, Int((size.height * renderScale).rounded()))
        let outputSize = CGSize(width: outputWidth, height: outputHeight)

        let snapshot = VideoExportSnapshot(
            gridSize: template.size,
            positions: template.points,
            colors: template.colors,
            background: template.background,
            smoothsColors: smoothsColors,
            blurRadius: blurRadius,
            showDots: showDots,
            shouldAnimate: animate,
            renderScale: renderScale
        )

        let exportTask = Task.detached(priority: .userInitiated) {
            let exportConfig = VideoExportConfig(
                outputURL: outputURL,
                viewSize: size,
                outputSize: outputSize,
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
        smoothsColors: Bool = true,
        renderScale: CGFloat = 1.0
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
            renderScale: renderScale
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
        guard duration > 0 else {
            throw VideoExportError.invalidConfiguration("Duration must be greater than 0.")
        }

        guard frameRate > 0 else {
            throw VideoExportError.invalidConfiguration("Frame rate must be greater than 0.")
        }

        guard size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0 else {
            throw VideoExportError.invalidConfiguration("Video size must be finite and greater than 0.")
        }

        guard renderScale.isFinite, renderScale > 0 else {
            throw VideoExportError.invalidConfiguration("Render scale must be finite and greater than 0.")
        }

        let expectedCount = template.size * template.size
        guard template.size > 0 else {
            throw VideoExportError.invalidConfiguration("Template size must be greater than 0.")
        }

        guard template.points.count == expectedCount else {
            throw VideoExportError.invalidConfiguration(
                "Template points count must equal size * size."
            )
        }

        guard template.colors.count == expectedCount else {
            throw VideoExportError.invalidConfiguration(
                "Template colors count must equal size * size."
            )
        }
    }
}
#endif
