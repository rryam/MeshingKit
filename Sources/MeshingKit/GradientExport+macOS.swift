//
//  GradientExport+macOS.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

#if os(macOS)
import AppKit

/// Errors that can occur when saving to disk.
public enum SaveToDiskError: Error, Sendable {
    case userCancelled
    case cgImageCreationFailed
    case imageEncodingFailed(Error)
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
