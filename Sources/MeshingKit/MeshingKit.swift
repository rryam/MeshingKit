// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

/// A structure that provides utility functions for creating mesh gradients.
public struct MeshingKit {
    
    /// Creates a `MeshGradient` from a given `GradientTemplate`.
    ///
    /// This function takes a `GradientTemplate` and converts it into a `MeshGradient`,
    /// using the template's size, points, and colors.
    ///
    /// - Parameter template: A `GradientTemplate` containing the gradient's specifications.
    /// - Returns: A `MeshGradient` instance created from the provided template.
    public static func gradient(template: GradientTemplate) -> MeshGradient {
        MeshGradient(width: template.size, height: template.size, points: template.points, colors: template.colors)
    }
}