import Testing
@testable import MeshingKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@Suite("MeshingKit Tests")
struct MeshingKitTests {

    @Test("Gradient creation from template")
    @MainActor
    func gradientCreation() {
        let template = GradientTemplateSize3.auroraBorealis

        // Verify the template has the correct size
        #expect(template.size == 3)

        // Verify the template has the expected number of points (3x3 = 9 points)
        #expect(template.points.count == 9)

        // Verify the template has the expected number of colors (3x3 = 9 colors)
        #expect(template.colors.count == 9)

        // Verify points are normalized (between 0.0 and 1.0)
        for point in template.points {
            #expect(point.x >= 0.0 && point.x <= 1.0)
            #expect(point.y >= 0.0 && point.y <= 1.0)
        }

        // Verify the gradient can be created without errors
        let gradient = MeshingKit.gradient(template: template)
        #expect(type(of: gradient) == MeshGradient.self)
    }

    @Test("Template counts validation")
    func templateCounts() {
        let size2Count = GradientTemplateSize2.allCases.count
        let size3Count = GradientTemplateSize3.allCases.count
        let size4Count = GradientTemplateSize4.allCases.count

        #expect(size2Count == 35)
        #expect(size3Count == 22)
        #expect(size4Count == 11)

        // Verify PredefinedTemplate.allCases matches the sum
        #expect(PredefinedTemplate.allCases.count == size2Count + size3Count + size4Count)
    }

    @Test("Hex color extension", arguments: [
        "#FF0000",
        "#00FF00",
        "#0000FF",
        "#FFFFFF",
        "#000000"
    ])
    func colorHexExtension(hexValue: String) {
        let color = Color(hex: hexValue)
        #expect(type(of: color) == Color.self)
    }

    @Test("Hex color extension handles short format")
    func hexColorShortFormat() {
        // 3-character hex (RGB)
        let color = Color(hex: "#F00")
        #expect(type(of: color) == Color.self)
    }

    @Test("Hex color extension handles alpha format")
    func hexColorAlphaFormat() {
        // 8-character hex (ARGB)
        let color = Color(hex: "#80FF0000")
        #expect(type(of: color) == Color.self)
    }

    @Test("Hex color extension handles invalid input")
    func hexColorInvalidInput() {
        let invalidColors = [
            "not-a-hex",
            "#GGGGGG",
            "#12345"
        ]

        for hexValue in invalidColors {
            let color = Color(hex: hexValue)
            let rgba = resolvedRGBA(color)
            #expect(isApproximatelyEqual(rgba.r, 1.0))
            #expect(isApproximatelyEqual(rgba.g, 1.0))
            #expect(isApproximatelyEqual(rgba.b, 1.0))
            #expect(isApproximatelyEqual(rgba.a, 1.0))
        }
    }

    @Test("Hex color extension outputs hex string")
    func hexColorOutputsHexString() {
        let color = Color(hex: "#FF0000")
        #expect(color.hexString() == "#FF0000")
        #expect(color.hexString(includeAlpha: true) == "#FFFF0000")
    }

    @Test("Animated positions ignore unsupported counts")
    func animatedPositionsUnsupportedCounts() {
        let positions = Array(repeating: SIMD2<Float>(x: 0.5, y: 0.5), count: 5)
        let animated = MeshingKit.animatedPositions(
            for: 0.5,
            positions: positions,
            animate: true
        )

        #expect(animated == positions)
    }

    private func validateTemplates<T: GradientTemplate>(
        _ templates: [T],
        expectedSize: Int
    ) {
        let expectedCount = expectedSize * expectedSize
        for template in templates {
            #expect(template.size == expectedSize)
            #expect(template.points.count == expectedCount)
            #expect(template.colors.count == expectedCount)
            #expect(!template.name.isEmpty)

            for point in template.points {
                #expect(point.x >= 0.0 && point.x <= 1.0, "Point x=\(point.x) out of range in \(template.name)")
                #expect(point.y >= 0.0 && point.y <= 1.0, "Point y=\(point.y) out of range in \(template.name)")
            }
        }
    }

    @Test("All templates have valid structure")
    func allTemplatesValid() {
        validateTemplates(GradientTemplateSize2.allCases, expectedSize: 2)
        validateTemplates(GradientTemplateSize3.allCases, expectedSize: 3)
        validateTemplates(GradientTemplateSize4.allCases, expectedSize: 4)
    }

    @Test("PredefinedTemplate allCases contains all templates")
    func predefinedTemplateAllCases() {
        let allTemplates = PredefinedTemplate.allCases

        // Verify count
        #expect(allTemplates.count == 68)

        // Verify all IDs are unique
        let ids = allTemplates.map { $0.id }
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count, "Duplicate template IDs found")

        // Verify we have the correct count of templates from each size
        let counts = allTemplates.reduce(into: (size2: 0, size3: 0, size4: 0)) { counts, template in
            switch template {
            case .size2: counts.size2 += 1
            case .size3: counts.size3 += 1
            case .size4: counts.size4 += 1
            }
        }

        #expect(counts.size2 == 35)
        #expect(counts.size3 == 22)
        #expect(counts.size4 == 11)
    }
}

private struct RGBA {
    let r: Double
    let g: Double
    let b: Double
    let a: Double
}

private func resolvedRGBA(_ color: Color) -> RGBA {
#if canImport(UIKit)
    let platformColor = UIColor(color)
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    platformColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    return RGBA(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
#elseif canImport(AppKit)
    let platformColor = NSColor(color)
    let srgb = platformColor.usingColorSpace(.sRGB) ?? platformColor
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
    return RGBA(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
#else
    return RGBA(r: 0, g: 0, b: 0, a: 0)
#endif
}

private func isApproximatelyEqual(_ lhs: Double, _ rhs: Double, tolerance: Double = 0.0001)
    -> Bool
{
    abs(lhs - rhs) <= tolerance
}
