//
//  GradientTemplate.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/14/24.
//

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
  public init(name: String, size: Int, points: [SIMD2<Float>], colors: [Color], background: Color) {
    self.name = name
    self.size = size
    self.points = points
    self.colors = colors
    self.background = background
  }
}
