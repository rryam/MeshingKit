import Testing
@testable import MeshingKit
import SwiftUI

@Suite("PredefinedTemplate Tests")
struct PredefinedTemplateTests {

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
}
