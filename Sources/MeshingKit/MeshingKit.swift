//
//  MeshingKit.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/14/24.
//

import SwiftUI

/// A structure that provides utility functions for creating mesh gradients.
public struct MeshingKit: Sendable {

  /// Creates a `MeshGradient` from a given `GradientTemplateSize3`.
  ///
  /// This function takes a `GradientTemplateSize3` and converts it into a `MeshGradient`,
  /// using the template's size, points, and colors.
  ///
  /// - Parameter template: A `GradientTemplateSize3` containing the gradient's specifications.
  /// - Returns: A `MeshGradient` instance created from the provided template.
  @MainActor public static func gradientSize3(template: GradientTemplateSize3) -> MeshGradient {
    MeshGradient(width: template.size, height: template.size, points: template.points, colors: template.colors)
  }

  /// Creates a `MeshGradient` from a given `GradientTemplateSize2`.
  ///
  /// This function takes a `GradientTemplateSize2` and converts it into a `MeshGradient`,
  /// using the template's size, points, and colors.
  ///
  /// - Parameter template: A `GradientTemplateSize2` containing the gradient's specifications.
  /// - Returns: A `MeshGradient` instance created from the provided template.
  @MainActor public static func gradientSize2(template: GradientTemplateSize2) -> MeshGradient {
    MeshGradient(width: template.size, height: template.size, points: template.points, colors: template.colors)
  }

  /// Creates a `MeshGradient` from a given `GradientTemplateSize4`.
  ///
  /// This function takes a `GradientTemplateSize4` and converts it into a `MeshGradient`,
  /// using the template's size, points, and colors.
  ///
  /// - Parameter template: A `GradientTemplateSize4` containing the gradient's specifications.
  /// - Returns: A `MeshGradient` instance created from the provided template.
  @MainActor public static func gradientSize4(template: GradientTemplateSize4) -> MeshGradient {
    MeshGradient(width: template.size, height: template.size, points: template.points, colors: template.colors)
  }

  /// Creates an animated `MeshGradient` view from a given `GradientTemplateSize3`.
  ///
  /// This function takes a `GradientTemplateSize3` and creates an animated `MeshGradient` view,
  /// using the template's size, points, colors, and background.
  ///
  /// - Parameters:
  ///   - template: A `GradientTemplateSize3` containing the gradient's specifications.
  ///   - showAnimation: A binding to control the animation's play/pause state.
  /// - Returns: A view containing the animated `MeshGradient`.
  @MainActor public static func animatedGradientSize3(template: GradientTemplateSize3, showAnimation: Binding<Bool>) -> some View {
    AnimatedMeshGradientView(
      gridSize: template.size,
      showAnimation: showAnimation,
      positions: template.points,
      colors: template.colors,
      background: template.background
    )
  }

  /// Creates an animated `MeshGradient` view from a given `GradientTemplateSize4`.
  ///
  /// This function takes a `GradientTemplateSize4` and creates an animated `MeshGradient` view,
  /// using the template's size, points, colors, and background.
  ///
  /// - Parameters:
  ///   - template: A `GradientTemplateSize4` containing the gradient's specifications.
  ///   - showAnimation: A binding to control the animation's play/pause state.
  /// - Returns: A view containing the animated `MeshGradient`.
  @MainActor public static func animatedGradientSize4(template: GradientTemplateSize4, showAnimation: Binding<Bool>) -> some View {
    AnimatedMeshGradientView(
      gridSize: template.size,
      showAnimation: showAnimation,
      positions: template.points,
      colors: template.colors,
      background: template.background
    )
  }
}
