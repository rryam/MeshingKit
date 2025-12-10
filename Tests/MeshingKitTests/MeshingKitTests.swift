import Testing
@testable import MeshingKit
import SwiftUI

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

    @Test("All Size2 templates have valid structure")
    func allSize2TemplatesValid() {
        for template in GradientTemplateSize2.allCases {
            #expect(template.size == 2)
            #expect(template.points.count == 4)
            #expect(template.colors.count == 4)
            #expect(!template.name.isEmpty)

            for point in template.points {
                #expect(point.x >= 0.0 && point.x <= 1.0, "Point x=\(point.x) out of range in \(template.name)")
                #expect(point.y >= 0.0 && point.y <= 1.0, "Point y=\(point.y) out of range in \(template.name)")
            }
        }
    }

    @Test("All Size3 templates have valid structure")
    func allSize3TemplatesValid() {
        for template in GradientTemplateSize3.allCases {
            #expect(template.size == 3)
            #expect(template.points.count == 9)
            #expect(template.colors.count == 9)
            #expect(!template.name.isEmpty)

            for point in template.points {
                #expect(point.x >= 0.0 && point.x <= 1.0, "Point x=\(point.x) out of range in \(template.name)")
                #expect(point.y >= 0.0 && point.y <= 1.0, "Point y=\(point.y) out of range in \(template.name)")
            }
        }
    }

    @Test("All Size4 templates have valid structure")
    func allSize4TemplatesValid() {
        for template in GradientTemplateSize4.allCases {
            #expect(template.size == 4)
            #expect(template.points.count == 16)
            #expect(template.colors.count == 16)
            #expect(!template.name.isEmpty)

            for point in template.points {
                #expect(point.x >= 0.0 && point.x <= 1.0, "Point x=\(point.x) out of range in \(template.name)")
                #expect(point.y >= 0.0 && point.y <= 1.0, "Point y=\(point.y) out of range in \(template.name)")
            }
        }
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

        // Verify we have templates from each size
        let size2Templates = allTemplates.filter {
            if case .size2 = $0 { return true }
            return false
        }
        let size3Templates = allTemplates.filter {
            if case .size3 = $0 { return true }
            return false
        }
        let size4Templates = allTemplates.filter {
            if case .size4 = $0 { return true }
            return false
        }

        #expect(size2Templates.count == 35)
        #expect(size3Templates.count == 22)
        #expect(size4Templates.count == 11)
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
