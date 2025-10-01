import XCTest
@testable import MeshingKit
import SwiftUI

final class MeshingKitTests: XCTestCase {

    @MainActor
    func testMeshingKitCreation() {
        // Test that we can create a basic gradient
        let gradient = MeshingKit.gradient(template: GradientTemplateSize3.auroraBorealis)
        XCTAssertNotNil(gradient)
    }

    func testTemplateCounts() {
        // Verify template counts
        let size2Count = GradientTemplateSize2.allCases.count
        let size3Count = GradientTemplateSize3.allCases.count
        let size4Count = GradientTemplateSize4.allCases.count

        print("Size 2x2 templates: \(size2Count)")
        print("Size 3x3 templates: \(size3Count)")
        print("Size 4x4 templates: \(size4Count)")

        XCTAssertGreaterThan(size2Count, 0)
        XCTAssertGreaterThan(size3Count, 0)
        XCTAssertGreaterThan(size4Count, 0)
    }

    func testColorHexExtension() {
        // Test hex color extension
        let redColor = Color(hex: "#FF0000")
        let blueColor = Color(hex: "#0000FF")

        // These should not crash
        _ = redColor
        _ = blueColor

        XCTAssertNoThrow(Color(hex: "#FF0000"))
        XCTAssertNoThrow(Color(hex: "#00FF00"))
        XCTAssertNoThrow(Color(hex: "#0000FF"))
    }
}