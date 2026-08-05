import Testing
@testable import MeshingKit
import SwiftUI
import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif
#if canImport(AppKit)
import AppKit
#endif

@Suite("Output Fidelity Tests")
struct OutputFidelityTests {

#if canImport(AVFoundation) && canImport(CoreImage) && (canImport(UIKit) || canImport(AppKit))
    @Test("Output size is rounded to even dimensions to match the H.264 encoder")
    func outputSizeIsEven() {
        #expect(
            MeshingKit.calculateOutputSize(
                from: CGSize(width: 321, height: 241), renderScale: 1
            ) == CGSize(width: 320, height: 240)
        )
        #expect(
            MeshingKit.calculateOutputSize(
                from: CGSize(width: 100, height: 100), renderScale: 1.5
            ) == CGSize(width: 150, height: 150)
        )
        // Never collapse to a zero-sized video.
        #expect(
            MeshingKit.calculateOutputSize(
                from: CGSize(width: 1, height: 1), renderScale: 1
            ) == CGSize(width: 2, height: 2)
        )
    }

    @Test("Odd requested dimensions produce an even, self-consistent video size")
    func oddVideoDimensions() async throws {
        let url = try await MeshingKit.exportVideo(
            template: .size2(.mysticTwilight),
            size: CGSize(width: 321, height: 241),
            duration: 1.0,
            frameRate: 2
        )
        defer { try? FileManager.default.removeItem(at: url) }

        let asset = AVURLAsset(url: url)
        let track = try #require(try await asset.loadTracks(withMediaType: .video).first)
        let dimensions = try await track.load(.naturalSize)

        // H.264 rounds odd dimensions down; MeshingKit must request the same even
        // size it draws into, so the encoded track matches exactly.
        #expect(dimensions.width.truncatingRemainder(dividingBy: 2) == 0)
        #expect(dimensions.height.truncatingRemainder(dividingBy: 2) == 0)
        #expect(dimensions == CGSize(width: 320, height: 240))
    }
#endif

#if canImport(AppKit)
    @Test("JPEG export flattens transparent corners to white, not black")
    @MainActor
    func jpegFlattensAlpha() throws {
        let gradient = MeshingKit.gradient(template: GradientTemplateSize2.mysticTwilight)
            .frame(width: 100, height: 100)
            .cornerRadius(12)
        let renderer = ImageRenderer(content: gradient)
        renderer.proposedSize = ProposedViewSize(width: 100, height: 100)

        let cgImage = try #require(renderer.cgImage)
        let flattened = try #require(MeshingKit.flattenedOnWhite(cgImage))
        let jpegData = try #require(
            NSBitmapImageRep(cgImage: flattened)
                .representation(using: .jpeg, properties: [.compressionFactor: 0.9])
        )
        let decoded = try #require(NSBitmapImageRep(data: jpegData))
        let corner = try #require(decoded.colorAt(x: 1, y: 1)?.usingColorSpace(.sRGB))

        #expect(corner.redComponent > 0.9)
        #expect(corner.greenComponent > 0.9)
        #expect(corner.blueComponent > 0.9)
    }
#endif
}
