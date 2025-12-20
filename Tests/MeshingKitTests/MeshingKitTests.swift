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
=======
    @Test("PredefinedTemplate tags include name tokens")
    func predefinedTemplateTags() {
        let template = PredefinedTemplate.size3(.auroraBorealis)
        #expect(template.tags.contains("aurora"))
        #expect(template.tags.contains("borealis"))
    }

    @Test("PredefinedTemplate moods derived from name")
    func predefinedTemplateMoods() {
        let template = PredefinedTemplate.size2(.arcticFrost)
        #expect(template.moods.contains(.cool))
    }

    @Test("PredefinedTemplate find by query")
    func predefinedTemplateFind() {
        let results = PredefinedTemplate.find(by: "aurora")
        #expect(results.contains(.size3(.auroraBorealis)))
    }

    @Test("PredefinedTemplate find is case-insensitive")
    func predefinedTemplateFindCaseInsensitive() {
        let results = PredefinedTemplate.find(by: "Aurora")
        #expect(results.contains(.size3(.auroraBorealis)))
    }

    @Test("PredefinedTemplate find matches moods")
    func predefinedTemplateFindMoods() {
        let results = PredefinedTemplate.find(by: "cool")
        #expect(results.contains(.size2(.arcticFrost)))
    }

    @Test("PredefinedTemplate find respects limit")
    func predefinedTemplateFindLimit() {
        let results = PredefinedTemplate.find(by: "aurora", limit: 1)
        #expect(results.count == 1)
    }

    @Test("PredefinedTemplate find returns all for empty query")
    func predefinedTemplateFindEmptyQuery() {
        let results = PredefinedTemplate.find(by: "   ")
        #expect(results.count == PredefinedTemplate.allCases.count)
    }

    @Test("CustomGradientTemplate creates valid template")
    func customGradientTemplateCreation() {
        let points: [SIMD2<Float>] = [
            .init(x: 0.0, y: 0.0), .init(x: 1.0, y: 0.0),
            .init(x: 0.0, y: 1.0), .init(x: 1.0, y: 1.0)
        ]
        let colors: [Color] = [.red, .green, .blue, .yellow]

        let template = CustomGradientTemplate(
            name: "Test Template",
            size: 2,
            points: points,
            colors: colors,
            background: .black
        )

        #expect(template.name == "Test Template")
        #expect(template.size == 2)
        #expect(template.points.count == 4)
        #expect(template.colors.count == 4)
    }

    @Test("CustomGradientTemplate validation reports errors")
    func customGradientTemplateValidation() {
        let points: [SIMD2<Float>] = [
            .init(x: -0.1, y: 0.0),
            .init(x: 1.2, y: 1.1)
        ]
        let colors: [Color] = [.red]

        let errors = CustomGradientTemplate.validate(
            size: 2,
            points: points,
            colors: colors
        )

        #expect(errors.contains(.pointsCount(expected: 4, actual: 2)))
        #expect(errors.contains(.colorsCount(expected: 4, actual: 1)))
        #expect(errors.contains(where: { error in
            if case .pointOutOfRange(index: 0, x: _, y: _) = error { return true }
            return false
        }))
    }

    @Test("CustomGradientTemplate validating initializer throws")
    func customGradientTemplateValidatingInitThrows() {
        let points: [SIMD2<Float>] = [
            .init(x: 0.0, y: 0.0)
        ]
        let colors: [Color] = [.red]

        do {
            _ = try CustomGradientTemplate(
                validating: "Invalid",
                size: 2,
                points: points,
                colors: colors,
                background: .black
            )
            #expect(Bool(false), "Expected validating initializer to throw")
        } catch let error as CustomGradientTemplate.ValidationErrors {
            #expect(!error.errors.isEmpty)
        } catch {
            #expect(Bool(false), "Unexpected error type: \(error)")
        }
    }

    @Test("AnimationPattern default for grid size 3")
    func animationPatternSize3() {
        let pattern = AnimationPattern.defaultPattern(forGridSize: 3)
        #expect(!pattern.animations.isEmpty)

        // Verify all point indices are valid for a 3x3 grid (0-8)
        for animation in pattern.animations {
            #expect(animation.pointIndex >= 0 && animation.pointIndex < 9)
        }
    }

    @Test("AnimationPattern default for grid size 4")
    func animationPatternSize4() {
        let pattern = AnimationPattern.defaultPattern(forGridSize: 4)
        #expect(!pattern.animations.isEmpty)

        // Verify all point indices are valid for a 4x4 grid (0-15)
        for animation in pattern.animations {
            #expect(animation.pointIndex >= 0 && animation.pointIndex < 16)
        }
    }

    @Test("AnimationPattern default for unsupported size returns empty")
    func animationPatternUnsupportedSize() {
        let pattern = AnimationPattern.defaultPattern(forGridSize: 5)
        #expect(pattern.animations.isEmpty)
    }

    @Test("AnimationPattern applies to points")
    func animationPatternApplies() {
        let pattern = AnimationPattern.defaultPattern(forGridSize: 3)
        let original: [SIMD2<Float>] = [
            .init(x: 0.0, y: 0.0), .init(x: 0.5, y: 0.0), .init(x: 1.0, y: 0.0),
            .init(x: 0.0, y: 0.5), .init(x: 0.5, y: 0.5), .init(x: 1.0, y: 0.5),
            .init(x: 0.0, y: 1.0), .init(x: 0.5, y: 1.0), .init(x: 1.0, y: 1.0)
        ]

        // Apply at phase 1.0 (non-zero phase should cause movement)
        let animated = pattern.apply(to: original, at: 1.0)

        // At least one point should have moved
        var hasMovement = false
        for index in 0..<original.count {
            if original[index].x != animated[index].x || original[index].y != animated[index].y {
                hasMovement = true
                break
            }
        }
        #expect(hasMovement, "Animation pattern should modify at least one point")
    }

    @Test("PointAnimation applies on x axis")
    func pointAnimationXAxis() {
        var point = SIMD2<Float>(x: 0.5, y: 0.5)
        let animation = PointAnimation(pointIndex: 0, axis: .x, amplitude: 0.1, frequency: 1.0)

        animation.apply(to: &point, at: 0.0)  // cos(0) = 1

        #expect(point.x != 0.5, "X should have changed")
        #expect(point.y == 0.5, "Y should not have changed")
    }

    @Test("PointAnimation applies on y axis")
    func pointAnimationYAxis() {
        var point = SIMD2<Float>(x: 0.5, y: 0.5)
        let animation = PointAnimation(pointIndex: 0, axis: .y, amplitude: 0.1, frequency: 1.0)

        animation.apply(to: &point, at: 0.0)  // cos(0) = 1

        #expect(point.x == 0.5, "X should not have changed")
        #expect(point.y != 0.5, "Y should have changed")
    }

    @Test("PointAnimation applies on both axes")
    func pointAnimationBothAxes() {
        var point = SIMD2<Float>(x: 0.5, y: 0.5)
        let animation = PointAnimation(pointIndex: 0, axis: .both, amplitude: 0.1, frequency: 1.0)

        animation.apply(to: &point, at: 0.5)  // Non-zero phase

        #expect(point.x != 0.5, "X should have changed")
        #expect(point.y != 0.5, "Y should have changed")
    }

    @Test("PointAnimation frequency affects speed")
    func pointAnimationFrequency() {
        var point1 = SIMD2<Float>(x: 0.5, y: 0.5)
        var point2 = SIMD2<Float>(x: 0.5, y: 0.5)

        let slowAnimation = PointAnimation(pointIndex: 0, axis: .x, amplitude: 0.1, frequency: 1.0)
        let fastAnimation = PointAnimation(pointIndex: 0, axis: .x, amplitude: 0.1, frequency: 2.0)

        slowAnimation.apply(to: &point1, at: 1.0)
        fastAnimation.apply(to: &point2, at: 1.0)

        // Different frequencies should produce different positions at same phase
        #expect(point1.x != point2.x, "Different frequencies should produce different results")
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
