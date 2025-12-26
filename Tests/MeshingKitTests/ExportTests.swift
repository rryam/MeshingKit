import Testing
@testable import MeshingKit
import SwiftUI
import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif

@Suite("Export Tests")
struct ExportTests {

    @Test("Export helpers generate snippets")
    func exportHelpersSnippets() {
        let template = GradientTemplateSize2.mysticTwilight
        let swiftUIStops = MeshingKit.swiftUIStopsSnippet(template: template)
        let swiftUIStopsWithAlpha = MeshingKit.swiftUIStopsSnippet(
            template: template,
            includeAlpha: true
        )
        let cssStops = MeshingKit.cssLinearGradientSnippet(template: template)
        let cssStopsWithAlpha = MeshingKit.cssLinearGradientSnippet(
            template: template,
            includeAlpha: true
        )

        #expect(swiftUIStops.contains("Color(hex:"))
        #expect(swiftUIStopsWithAlpha.contains("Color(hex: \"#FF"))
        #expect(cssStops.contains("linear-gradient("))
        #expect(cssStops.contains("#"))
        #expect(cssStopsWithAlpha.contains("rgba("))
    }

    @Test("Export helpers generate stops")
    func exportHelpersStops() {
        let template = GradientTemplateSize2.mysticTwilight
        let stops = MeshingKit.previewStops(template: template)

        #expect(stops.count == template.colors.count)
        #expect(isApproximatelyEqual(Double(stops.first?.location ?? 0), 0))
        #expect(isApproximatelyEqual(Double(stops.last?.location ?? 0), 1))
    }

    @Test("Snapshot helpers generate CGImage")
    func snapshotHelpersCGImage() async {
        let image = await MeshingKit.snapshotCGImage(
            template: .size2(.mysticTwilight),
            size: CGSize(width: 100, height: 100)
        )

        #expect(image != nil)
    }

    @Test("Video export rejects invalid configuration")
    func exportVideoRejectsInvalidConfiguration() async {
        do {
            _ = try await MeshingKit.exportVideo(
                template: .size2(.mysticTwilight),
                size: .zero,
                duration: 0,
                frameRate: 0
            )
            #expect(Bool(false), "Expected exportVideo to throw for invalid configuration.")
        } catch let error as VideoExportError {
            if case .invalidConfiguration = error {
                #expect(Bool(true))
            } else {
                #expect(Bool(false), "Unexpected error: \(error)")
            }
        } catch {
            #expect(Bool(false), "Unexpected error type: \(error)")
        }
    }

#if canImport(AVFoundation) && canImport(CoreImage) && (canImport(UIKit) || canImport(AppKit))
    @Test("Video export writes a file")
    func exportVideoWritesFile() async throws {
        let url = try await MeshingKit.exportVideo(
            template: .size2(.mysticTwilight),
            size: CGSize(width: 320, height: 320),
            duration: 1.0,
            frameRate: 2
        )

        #expect(FileManager.default.fileExists(atPath: url.path))
#if canImport(AVFoundation)
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        #expect(duration.isNumeric)
        #expect(duration.seconds > 0)
#endif
        let keepVideo = ProcessInfo.processInfo.environment["MESHKIT_KEEP_VIDEO"] == "1"
        if keepVideo {
            print("MeshingKit export video saved at: \(url.path)")
        } else {
            try? FileManager.default.removeItem(at: url)
        }
    }
#endif
}

private func isApproximatelyEqual(_ lhs: Double, _ rhs: Double, tolerance: Double = 0.0001)
    -> Bool
{
    abs(lhs - rhs) <= tolerance
}
