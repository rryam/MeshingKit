import SwiftUI

/// A structure that defines a template for creating mesh gradients.
///
/// `GradientTemplate` encapsulates all the necessary information to generate a mesh gradient,
/// including its name, size, control points, colors, and background color.
public struct GradientTemplate: Sendable {

    /// The name of the gradient template.
    let name: String

    /// The size of the gradient, representing both width and height in pixels.
    let size: Int

    /// An array of 2D points that define the control points of the gradient.
    ///
    /// Each point is represented as a `SIMD2<Float>` where:
    /// - The x-component represents the horizontal position (0.0 to 1.0).
    /// - The y-component represents the vertical position (0.0 to 1.0).
    let points: [SIMD2<Float>]

    /// An array of colors associated with the control points.
    ///
    /// The colors in this array correspond to the points in the `points` array.
    let colors: [Color]

    /// The background color of the gradient.
    ///
    /// This color is used as the base color for areas not directly affected by the control points.
    let background: Color

    /// Creates a new gradient template with the specified parameters.
    ///
    /// - Parameters:
    ///   - name: A string that identifies the gradient template.
    ///   - size: The dimensions of the gradient in pixels (width and height are equal).
    ///   - points: An array of `SIMD2<Float>` values representing the control points.
    ///   - colors: An array of `Color` values corresponding to each control point.
    ///   - background: The base color of the gradient.
    ///
    /// - Note: The number of elements in `points` should match the number of elements in `colors`.
    init(name: String, size: Int, points: [SIMD2<Float>], colors: [Color], background: Color) {
        self.name = name
        self.size = size
        self.points = points
        self.colors = colors
        self.background = background
    }
}

extension GradientTemplate {

    /// A predefined gradient template representing an "Intelligence" theme.
    ///
    /// This gradient uses a combination of blue, purple, and orange hues
    /// to create a vibrant and dynamic appearance.
    static let intelligence = GradientTemplate(
        name: "Intelligence",
        size: 3,
        points: [
            .init(x: 0.000, y: 0.000), .init(x: 0.400, y: 0.000), .init(x: 1.000, y: 0.000),
            .init(x: 0.000, y: 0.450), .init(x: 0.653, y: 0.670), .init(x: 1.000, y: 0.200),
            .init(x: 0.000, y: 1.000), .init(x: 0.550, y: 1.000), .init(x: 1.000, y: 1.000)
        ],
        colors: [
            Color(hex: "#1BB1F9"), Color(hex: "#648EF2"), Color(hex: "#AE6FEE"),
            Color(hex: "#9B79F1"), Color(hex: "#ED50EB"), Color(hex: "#F65490"),
            Color(hex: "#F74A6B"), Color(hex: "#F47F3E"), Color(hex: "#ED8D02")
        ],
        background: Color(hex: "#1BB1F9")
    )

    /// A predefined gradient template representing an "Aurora Borealis" theme.
    ///
    /// This gradient uses cool blues and greens to mimic the appearance
    /// of the Northern Lights against a dark night sky.
    static let auroraBorealis = GradientTemplate(
        name: "Aurora Borealis",
        size: 3,
        points: [
            .init(x: 0.000, y: 0.000), .init(x: 0.400, y: 0.000), .init(x: 1.000, y: 0.000),
            .init(x: 0.000, y: 0.450), .init(x: 0.900, y: 0.700), .init(x: 1.000, y: 0.200),
            .init(x: 0.000, y: 1.000), .init(x: 0.550, y: 1.000), .init(x: 1.000, y: 1.000)
        ],
        colors: [
            Color(hex: "#0073e6"), Color(hex: "#4da6ff"), Color(hex: "#b3d9ff"),
            Color(hex: "#00ff80"), Color(hex: "#66ffb3"), Color(hex: "#99ffcc"),
            Color(hex: "#004d40"), Color(hex: "#008577"), Color(hex: "#00a693")
        ],
        background: Color(hex: "#001a33")
    )
}
