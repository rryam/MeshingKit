//
//  MeshingKit.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/14/24.
//

import SwiftUI

/// A structure that provides utility functions for creating mesh gradients.
public struct MeshingKit {
    
    /// Creates a `MeshGradient` from a given `GradientTemplateSize3`.
    ///
    /// This function takes a `GradientTemplateSize3` and converts it into a `MeshGradient`,
    /// using the template's size, points, and colors.
    ///
    /// - Parameter template: A `GradientTemplateSize3` containing the gradient's specifications.
    /// - Returns: A `MeshGradient` instance created from the provided template.
    public static func gradientSize3(template: GradientTemplateSize3) -> MeshGradient {
        MeshGradient(width: template.size, height: template.size, points: template.points, colors: template.colors)
    }
}