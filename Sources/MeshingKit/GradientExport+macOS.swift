//
//  GradientExport+macOS.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

#if os(macOS)
import AppKit
import UniformTypeIdentifiers

/// Errors that can occur when saving to disk.
public enum SaveToDiskError: Error, Sendable {
    case userCancelled
    case cgImageCreationFailed
    case imageRenderingFailed
    case imageRepresentationCreationFailed
    case imageEncodingFailed(Error)
    case unsupportedFormat
}

/// Errors that can occur when saving video exports to disk.
public enum VideoSaveError: Error, Sendable {
    case userCancelled
    case fileMoveFailed(Error)
}

extension SaveToDiskError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Save was cancelled."
        case .cgImageCreationFailed:
            return "Unable to create image data from the rendered output."
        case .imageRenderingFailed:
            return "Failed to render the gradient image."
        case .imageRepresentationCreationFailed:
            return "Failed to prepare the image for saving."
        case .imageEncodingFailed(let error):
            return "Failed to write the image to disk: \(error.localizedDescription)"
        case .unsupportedFormat:
            return "Only PNG and JPG formats are supported for image exports."
        }
    }
}

extension VideoSaveError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Export was cancelled."
        case .fileMoveFailed(let error):
            return "Failed to move the exported video: \(error.localizedDescription)"
        }
    }
}

public extension MeshingKit {
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
        guard let fileType = format.fileType else {
            completion(.failure(SaveToDiskError.unsupportedFormat))
            return
        }

        let contentType: UTType = format == .jpg ? .jpeg : .png
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [contentType]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save Gradient Image"
        savePanel.message = "Choose a location to save your gradient image."
        savePanel.nameFieldLabel = "File name:"
        savePanel.nameFieldStringValue = "\(fileName).\(format.fileExtension)"

        savePanel.begin { response in
            guard response == .OK, var url = savePanel.url else {
                completion(.failure(SaveToDiskError.userCancelled))
                return
            }

            // Ensure correct extension
            let expectedExtension = format.fileExtension
            if url.pathExtension.lowercased() != expectedExtension {
                url = url.deletingPathExtension().appendingPathExtension(expectedExtension)
            }

            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                completion(.failure(SaveToDiskError.cgImageCreationFailed))
                return
            }

            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)

            let properties: [NSBitmapImageRep.PropertyKey: Any] = fileType == .jpeg
                ? [.compressionFactor: 0.9]
                : [:]

            guard let imageData = bitmapRep.representation(using: fileType, properties: properties) else {
                completion(.failure(SaveToDiskError.imageRepresentationCreationFailed))
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
            completion(.failure(SaveToDiskError.imageRenderingFailed))
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

    // MARK: - Video Export (macOS)
    /// Exports a gradient as a video file using a save panel dialog.
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
    ///   - renderScale: Render scale multiplier (default: 1.0).
    ///   - fileName: The default file name (default: "mesh-gradient").
    ///   - timeout: Maximum time allowed for export (default: 30 minutes).
    ///   - completion: Called with the result URL or error.
    @MainActor
    static func exportVideoToDisk(
        template: any GradientTemplate,
        size: CGSize,
        duration: TimeInterval = 5.0,
        frameRate: Int32 = 30,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        animate: Bool = true,
        smoothsColors: Bool = true,
        renderScale: CGFloat = 1.0,
        fileName: String = "mesh-gradient",
        timeout: TimeInterval = videoExportTimeout,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.mpeg4Movie]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save Gradient Video"
        savePanel.message = "Choose a location to save your gradient video."
        savePanel.nameFieldLabel = "File name:"
        savePanel.nameFieldStringValue = "\(fileName).mp4"

        savePanel.begin { response in
            guard response == .OK, var url = savePanel.url else {
                completion(.failure(VideoSaveError.userCancelled))
                return
            }

            if url.pathExtension.lowercased() != "mp4" {
                url = url.deletingPathExtension().appendingPathExtension("mp4")
            }

            Task {
                do {
                    let tempURL = try await exportVideo(
                        template: template,
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

                    do {
                        if FileManager.default.fileExists(atPath: url.path) {
                            try FileManager.default.removeItem(at: url)
                        }
                        try FileManager.default.moveItem(at: tempURL, to: url)
                        completion(.success(url))
                    } catch {
                        try? FileManager.default.removeItem(at: tempURL)
                        completion(.failure(VideoSaveError.fileMoveFailed(error)))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    /// Exports a predefined template as a video file using a save panel dialog.
    @MainActor
    static func exportVideoToDisk(
        template: PredefinedTemplate,
        size: CGSize,
        duration: TimeInterval = 5.0,
        frameRate: Int32 = 30,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        animate: Bool = true,
        smoothsColors: Bool = true,
        renderScale: CGFloat = 1.0,
        fileName: String = "mesh-gradient",
        timeout: TimeInterval = videoExportTimeout,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        exportVideoToDisk(
            template: template.baseTemplate,
            size: size,
            duration: duration,
            frameRate: frameRate,
            blurRadius: blurRadius,
            showDots: showDots,
            animate: animate,
            smoothsColors: smoothsColors,
            renderScale: renderScale,
            fileName: fileName,
            timeout: timeout,
            completion: completion
        )
    }

    /// Exports a gradient as a video file using a configuration and save panel.
    @MainActor
    static func exportVideoToDisk(
        template: any GradientTemplate,
        configuration: VideoExportConfiguration,
        fileName: String = "mesh-gradient",
        timeout: TimeInterval = videoExportTimeout,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        exportVideoToDisk(
            template: template,
            size: configuration.size,
            duration: configuration.duration,
            frameRate: configuration.frameRate,
            blurRadius: configuration.blurRadius,
            showDots: configuration.showDots,
            animate: configuration.animate,
            smoothsColors: configuration.smoothsColors,
            renderScale: configuration.renderScale,
            fileName: fileName,
            timeout: timeout,
            completion: completion
        )
    }

    /// Exports a predefined template as a video file using a configuration and save panel.
    @MainActor
    static func exportVideoToDisk(
        template: PredefinedTemplate,
        configuration: VideoExportConfiguration,
        fileName: String = "mesh-gradient",
        timeout: TimeInterval = videoExportTimeout,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        exportVideoToDisk(
            template: template.baseTemplate,
            configuration: configuration,
            fileName: fileName,
            timeout: timeout,
            completion: completion
        )
    }
}
#endif
