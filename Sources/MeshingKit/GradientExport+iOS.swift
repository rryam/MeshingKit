//
//  GradientExport+iOS.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

#if os(iOS)
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
        renderScale: CGFloat = 1.0,
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
                    smoothsColors: smoothsColors,
                    renderScale: renderScale
                )

                do {
                    let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                    guard status == .authorized else {
                        throw VideoExportError.photosPermissionDenied
                    }

                    try await PHPhotoLibrary.shared().performChanges {
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                    }

                    completion(.success(videoURL))
                } catch {
                    try? FileManager.default.removeItem(at: videoURL)
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Exports a gradient as a video using a configuration and saves it to the photo library.
    ///
    /// - Parameters:
    ///   - template: The gradient template to export.
    ///   - configuration: Video export configuration.
    ///   - completion: Called with the result containing a temporary file URL.
    ///     The caller is responsible for deleting this file after use.
    static func exportVideoToPhotoLibrary(
        template: any GradientTemplate,
        configuration: VideoExportConfiguration,
        completion: @escaping @Sendable (Result<URL, Error>) -> Void
    ) {
        exportVideoToPhotoLibrary(
            template: template,
            size: configuration.size,
            duration: configuration.duration,
            frameRate: configuration.frameRate,
            blurRadius: configuration.blurRadius,
            showDots: configuration.showDots,
            animate: configuration.animate,
            smoothsColors: configuration.smoothsColors,
            renderScale: configuration.renderScale,
            completion: completion
        )
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
        renderScale: CGFloat = 1.0,
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
            renderScale: renderScale,
            completion: completion
        )
    }

    /// Exports a predefined template as video to photo library using a configuration.
    ///
    /// - Parameter completion: Called with the result containing a temporary file URL.
    ///   The caller is responsible for deleting this file after use.
    static func exportVideoToPhotoLibrary(
        template: PredefinedTemplate,
        configuration: VideoExportConfiguration,
        completion: @escaping @Sendable (Result<URL, Error>) -> Void
    ) {
        exportVideoToPhotoLibrary(
            template: template.baseTemplate,
            configuration: configuration,
            completion: completion
        )
    }

}
#endif
