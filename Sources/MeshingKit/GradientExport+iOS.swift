//
//  GradientExport+iOS.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

#if os(iOS)
import Photos

public extension MeshingKit {
    // MARK: - Save to Photo Library

    /// Saves an image to the user's photo library.
    ///
    /// - Parameters:
    ///   - image: The image to save.
    ///   - completion: A completion handler called with the result.
    static func saveToPhotoAlbum(image: UIImage, completion: @escaping (Error?) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, nil, #selector(saveCompleted), nil)
    }

    @objc private static func saveCompleted(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully to photo library")
        }
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
    ///   - completion: Called when saving completes with an optional error.
    @MainActor
    static func saveGradientToPhotoAlbum(
        template: any GradientTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        smoothsColors: Bool = true,
        completion: @escaping (Error?) -> Void
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
            let errorMessage = "Failed to render image"
            completion(NSError(
                domain: "MeshingKit",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            ))
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
        completion: @escaping (Error?) -> Void
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
    ///   - completion: Called with the result.
    static func exportVideoToPhotoLibrary(
        template: any GradientTemplate,
        size: CGSize,
        duration: TimeInterval = 5.0,
        frameRate: Int32 = 30,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        animate: Bool = true,
        smoothsColors: Bool = true,
        completion: @escaping (Result<URL, Error>) -> Void
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
                    return
                }

                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }

                try? FileManager.default.removeItem(at: videoURL)
                completion(.success(videoURL))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Exports a predefined template as video to photo library.
    static func exportVideoToPhotoLibrary(
        template: PredefinedTemplate,
        size: CGSize,
        duration: TimeInterval = 5.0,
        frameRate: Int32 = 30,
        blurRadius: CGFloat = 0,
        showDots: Bool = false,
        animate: Bool = true,
        smoothsColors: Bool = true,
        completion: @escaping (Result<URL, Error>) -> Void
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
}
#endif
