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

    @Test("Video export rejects invalid timeout")
    func exportVideoRejectsInvalidTimeout() async {
        do {
            _ = try await MeshingKit.exportVideo(
                template: .size2(.mysticTwilight),
                size: CGSize(width: 320, height: 320),
                duration: 1,
                frameRate: 2,
                timeout: .infinity
            )
            #expect(Bool(false), "Expected exportVideo to throw for invalid timeout.")
        } catch let error as VideoExportError {
            if case .invalidConfiguration(let message) = error {
                #expect(message.contains("Timeout"))
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

    @Test("Video export uses custom animation pattern")
    func exportVideoUsesCustomAnimationPattern() async throws {
        let template = GradientTemplateSize3.auroraBorealis
        let size = CGSize(width: 200, height: 200)

        let pattern = AnimationPattern(animations: [
            PointAnimation(pointIndex: 4, axis: .both, amplitude: 0.45, frequency: 0.0)
        ])

        let urlDefault = try await MeshingKit.exportVideo(
            template: template, size: size, duration: 1, frameRate: 1
        )
        let urlCustom = try await MeshingKit.exportVideo(
            template: template, size: size, duration: 1, frameRate: 1, animationPattern: pattern
        )
        defer {
            try? FileManager.default.removeItem(at: urlDefault)
            try? FileManager.default.removeItem(at: urlCustom)
        }

        let generator1 = AVAssetImageGenerator(asset: AVURLAsset(url: urlDefault))
        generator1.appliesPreferredTrackTransform = true
        let generator2 = AVAssetImageGenerator(asset: AVURLAsset(url: urlCustom))
        generator2.appliesPreferredTrackTransform = true

        let frameDefault = try await image(at: .zero, generator: generator1)
        let frameCustom = try await image(at: .zero, generator: generator2)

        let centerDefault = sampleRGB(frameDefault, x: 100, y: 100)
        let centerCustom = sampleRGB(frameCustom, x: 100, y: 100)

        #expect(
            colorDistance(centerDefault, centerCustom) > 100,
            "Center pixel should differ between default and custom animation pattern exports"
        )
    }

    @Test("Video export ignores custom animation pattern when animate is false")
    func exportVideoIgnoresCustomAnimationPatternWhenAnimationDisabled() async throws {
        let template = GradientTemplateSize3.auroraBorealis
        let size = CGSize(width: 200, height: 200)

        let pattern = AnimationPattern(animations: [
            PointAnimation(pointIndex: 4, axis: .both, amplitude: 0.45, frequency: 0.0)
        ])

        let urlStatic = try await MeshingKit.exportVideo(
            template: template, size: size, duration: 1, frameRate: 1, animate: false
        )
        let urlStaticWithPattern = try await MeshingKit.exportVideo(
            template: template,
            size: size,
            duration: 1,
            frameRate: 1,
            animate: false,
            animationPattern: pattern
        )
        defer {
            try? FileManager.default.removeItem(at: urlStatic)
            try? FileManager.default.removeItem(at: urlStaticWithPattern)
        }

        let generator1 = AVAssetImageGenerator(asset: AVURLAsset(url: urlStatic))
        generator1.appliesPreferredTrackTransform = true
        let generator2 = AVAssetImageGenerator(asset: AVURLAsset(url: urlStaticWithPattern))
        generator2.appliesPreferredTrackTransform = true

        let frameStatic = try await image(at: .zero, generator: generator1)
        let frameStaticWithPattern = try await image(at: .zero, generator: generator2)

        let centerStatic = sampleRGB(frameStatic, x: 100, y: 100)
        let centerStaticWithPattern = sampleRGB(frameStaticWithPattern, x: 100, y: 100)

        #expect(
            colorDistance(centerStatic, centerStaticWithPattern) == 0,
            "Custom animation patterns should be ignored when animate is false"
        )
    }

    @Test("Video export preserves orientation for static frame")
    @MainActor
    func exportVideoPreservesOrientation() async throws {
        let size = CGSize(width: 180, height: 180)
        let margin = 20

        guard let snapshot = MeshingKit.snapshotCGImage(
            template: .size2(.tropicalParadise),
            size: size,
            scale: 1,
            smoothsColors: true
        ) else {
            #expect(Bool(false), "Expected snapshotCGImage to succeed.")
            return
        }

        let url = try await MeshingKit.exportVideo(
            template: .size2(.tropicalParadise),
            size: size,
            duration: 1.0,
            frameRate: 1,
            animate: false,
            smoothsColors: true,
            renderScale: 1
        )
        defer { try? FileManager.default.removeItem(at: url) }

        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        generator.appliesPreferredTrackTransform = true
        let frame = try await image(at: .zero, generator: generator)

        let snapTL = sampleRGB(snapshot, x: margin, y: margin)
        let snapTR = sampleRGB(snapshot, x: snapshot.width - margin - 1, y: margin)
        let snapBL = sampleRGB(snapshot, x: margin, y: snapshot.height - margin - 1)
        let snapBR = sampleRGB(snapshot, x: snapshot.width - margin - 1, y: snapshot.height - margin - 1)

        let videoTL = sampleRGB(frame, x: margin, y: margin)
        let videoTR = sampleRGB(frame, x: frame.width - margin - 1, y: margin)
        let videoBL = sampleRGB(frame, x: margin, y: frame.height - margin - 1)
        let videoBR = sampleRGB(frame, x: frame.width - margin - 1, y: frame.height - margin - 1)

        #expect(colorDistance(snapTL, videoTL) < colorDistance(snapTL, videoBL))
        #expect(colorDistance(snapTR, videoTR) < colorDistance(snapTR, videoBR))
        #expect(colorDistance(snapBL, videoBL) < colorDistance(snapBL, videoTL))
        #expect(colorDistance(snapBR, videoBR) < colorDistance(snapBR, videoTR))
    }
#endif
}

private func isApproximatelyEqual(_ lhs: Double, _ rhs: Double, tolerance: Double = 0.0001)
    -> Bool
{
    abs(lhs - rhs) <= tolerance
}

private func image(at time: CMTime, generator: AVAssetImageGenerator) async throws -> CGImage {
    let frame = try await generator.image(at: time)
    return frame.image
}

private func sampleRGB(_ image: CGImage, x: Int, y: Int) -> (r: Int, g: Int, b: Int) {
    let clampedX = max(0, min(image.width - 1, x))
    let clampedY = max(0, min(image.height - 1, y))

    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * image.width
    var data = [UInt8](repeating: 0, count: bytesPerRow * image.height)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

    data.withUnsafeMutableBytes { rawBuffer in
        guard let baseAddress = rawBuffer.baseAddress else { return }
        guard let context = CGContext(
            data: baseAddress,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
    }

    let offset = (clampedY * bytesPerRow) + (clampedX * bytesPerPixel)
    return (
        r: Int(data[offset]),
        g: Int(data[offset + 1]),
        b: Int(data[offset + 2])
    )
}

private func colorDistance(_ lhs: (r: Int, g: Int, b: Int), _ rhs: (r: Int, g: Int, b: Int)) -> Int {
    let dr = lhs.r - rhs.r
    let dg = lhs.g - rhs.g
    let db = lhs.b - rhs.b
    return dr * dr + dg * dg + db * db
}
