//
//  GradientTemplate.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/14/24.
//

import SwiftUI

/// A protocol that defines a template for creating mesh gradients.
///
/// `GradientTemplate` encapsulates all the necessary information to generate a mesh gradient,
/// including its name, size, control points, colors, and background color.
public protocol GradientTemplate: Sendable {

    /// The name of the gradient template.
    var name: String { get }

    /// The grid size of the gradient.
    ///
    /// For example, a size of `3` represents a 3×3 grid (9 control points/colors).
    var size: Int { get }

    /// An array of 2D points that define the control points of the gradient.
    ///
    /// Each point is represented as a `SIMD2<Float>` where:
    /// - The x-component represents the horizontal position (0.0 to 1.0).
    /// - The y-component represents the vertical position (0.0 to 1.0).
    var points: [SIMD2<Float>] { get }

    /// An array of colors associated with the control points.
    ///
    /// The colors in this array correspond to the points in the `points` array.
    var colors: [Color] { get }

    /// The background color of the gradient.
    ///
    /// This color is used as the base color for areas not directly affected by the control points.
    var background: Color { get }
}

/// A structure that implements the GradientTemplate protocol for custom gradients.
public struct CustomGradientTemplate: GradientTemplate {

    /// The name of the gradient template.
    public let name: String

    /// The grid size of the gradient.
    ///
    /// For example, a size of `4` represents a 4×4 grid (16 control points/colors).
    public let size: Int

    /// An array of 2D points that define the control points of the gradient.
    ///
    /// Each point is represented as a `SIMD2<Float>` where:
    /// - The x-component represents the horizontal position (0.0 to 1.0).
    /// - The y-component represents the vertical position (0.0 to 1.0).
    public let points: [SIMD2<Float>]

    /// An array of colors associated with the control points.
    ///
    /// The colors in this array correspond to the points in the `points` array.
    public let colors: [Color]

    /// The background color of the gradient.
    ///
    /// This color is used as the base color for areas not directly affected by the control points.
    public let background: Color

    /// Creates a new custom gradient template with the specified parameters.
    ///
    /// - Parameters:
    ///   - name: A string that identifies the gradient template.
    ///   - size: The grid size (width and height are equal).
    ///   - points: An array of `SIMD2<Float>` values representing the control points.
    ///   - colors: An array of `Color` values corresponding to each control point.
    ///   - background: The base color of the gradient.
    ///
    /// - Note: The number of elements in `points` should match the number of elements in `colors`.
    /// - Precondition: `size > 0`, `points.count == size * size`, `colors.count == size * size`,
    ///   and all points have coordinates in the range [0.0, 1.0].
    public init(
        name: String,
        size: Int,
        points: [SIMD2<Float>],
        colors: [Color],
        background: Color
    ) {
        let expectedCount = size * size
        precondition(size > 0, "Gradient size must be greater than 0")
        precondition(points.count == expectedCount,
                    "Expected \(expectedCount) points for size \(size), got \(points.count)")
        precondition(colors.count == expectedCount,
                    "Expected \(expectedCount) colors for size \(size), got \(colors.count)")

        // Validate point ranges
        for (index, point) in points.enumerated() {
            precondition(point.x >= 0.0 && point.x <= 1.0,
                        "Point at index \(index) has x coordinate \(point.x) outside valid range [0.0, 1.0]")
            precondition(point.y >= 0.0 && point.y <= 1.0,
                        "Point at index \(index) has y coordinate \(point.y) outside valid range [0.0, 1.0]")
        }

        self.name = name
        self.size = size
        self.points = points
        self.colors = colors
        self.background = background
    }
}
