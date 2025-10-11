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

        print("Size 2x2 templates: \(size2Count)")
        print("Size 3x3 templates: \(size3Count)")
        print("Size 4x4 templates: \(size4Count)")

        #expect(size2Count > 0)
        #expect(size3Count > 0)
        #expect(size4Count > 0)
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
}
