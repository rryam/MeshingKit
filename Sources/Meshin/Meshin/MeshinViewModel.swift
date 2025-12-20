//
//  MeshinViewModel.swift
//  Meshin
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI
import MeshingKit

/// View model for managing gradient templates and export operations.
@MainActor
final class MeshinViewModel: ObservableObject {
    @Published var selectedTemplate: PredefinedTemplate?
    @Published var showExportSheet: Bool = false
    @Published var isExporting: Bool = false
    @Published var exportError: String?
    @Published var exportSuccessMessage: String?

    private let exportSize: CGSize
    private let videoDuration: TimeInterval
    private let videoFrameRate: Int32

    init(
        exportSize: CGSize = CGSize(width: 1080, height: 1920),
        videoDuration: TimeInterval = 5.0,
        videoFrameRate: Int32 = 30
    ) {
        self.exportSize = exportSize
        self.videoDuration = videoDuration
        self.videoFrameRate = videoFrameRate
    }

    // MARK: - Export Operations

    #if os(iOS)
    /// Saves the selected gradient to the photo library.
    func saveToPhotoLibrary() {
        guard let template = selectedTemplate else { return }

        isExporting = true
        exportError = nil

        MeshingKit.saveGradientToPhotoAlbum(
            template: template,
            size: exportSize
        ) { [weak self] result in
            Task { @MainActor in
                self?.isExporting = false
                switch result {
                case .success:
                    self?.exportSuccessMessage = "Saved to photo library!"
                case .failure(let error):
                    self?.exportError = error.localizedDescription
                }
            }
        }
    }

    /// Exports the selected gradient as a video to the photo library.
    func exportVideoToPhotoLibrary() {
        guard let template = selectedTemplate else { return }

        isExporting = true
        exportError = nil

        MeshingKit.exportVideoToPhotoLibrary(
            template: template,
            size: exportSize,
            duration: videoDuration,
            frameRate: videoFrameRate
        ) { [weak self] result in
            Task { @MainActor in
                self?.isExporting = false
                switch result {
                case .success:
                    self?.exportSuccessMessage = "Video saved to photo library!"
                case .failure(let error):
                    self?.exportError = error.localizedDescription
                }
            }
        }
    }
    #endif

    #if os(macOS)
    /// Saves the selected gradient to disk.
    func saveToDisk(format: ExportFormat) {
        guard let template = selectedTemplate else { return }

        isExporting = true
        exportError = nil

        MeshingKit.saveGradientToDisk(
            template: template,
            size: exportSize,
            fileName: "mesh-gradient",
            format: format
        ) { [weak self] result in
            Task { @MainActor in
                self?.isExporting = false
                switch result {
                case .success(let url):
                    self?.exportSuccessMessage = "Saved to \(url.lastPathComponent)"
                case .failure(let error):
                    self?.exportError = error.localizedDescription
                }
            }
        }
    }

    /// Exports the selected gradient as a video to disk.
    func exportVideoToDisk() {
        guard let template = selectedTemplate else { return }

        isExporting = true
        exportError = nil

        Task {
            do {
                let url = try await MeshingKit.exportVideo(
                    template: template,
                    size: exportSize,
                    duration: videoDuration,
                    frameRate: videoFrameRate
                )
                isExporting = false
                exportSuccessMessage = "Video saved to \(url.lastPathComponent)"
            } catch {
                isExporting = false
                exportError = error.localizedDescription
            }
        }
    }
    #endif

    // MARK: - UI Helpers

    func showExportOptions() {
        showExportSheet = true
    }

    func dismissExportSheet() {
        showExportSheet = false
    }

    func clearMessages() {
        exportError = nil
        exportSuccessMessage = nil
    }
}

// MARK: - Export Format Helper

#if os(macOS)
extension MeshinViewModel {
    var availableExportFormats: [ExportFormat] {
        [.png, .jpg]
    }
}
#endif
