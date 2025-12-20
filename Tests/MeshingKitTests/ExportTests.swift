import Testing
@testable import MeshingKit
import SwiftUI

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
}

private func isApproximatelyEqual(_ lhs: Double, _ rhs: Double, tolerance: Double = 0.0001)
    -> Bool
{
    abs(lhs - rhs) <= tolerance
}
