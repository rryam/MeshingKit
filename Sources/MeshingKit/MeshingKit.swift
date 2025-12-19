//
//  MeshingKit.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/14/24.
//

import SwiftUI

/// A type alias for an array of 2D points used in mesh gradients.
///
/// Each point is represented as a `SIMD2<Float>` where:
/// - The x-component represents the horizontal position (0.0 to 1.0).
/// - The y-component represents the vertical position (0.0 to 1.0).
public typealias MeshPoints = [SIMD2<Float>]

/// A structure that provides utility functions for creating mesh gradients.
public struct MeshingKit: Sendable {

    /// Creates a `MeshGradient` from a given `GradientTemplateSize3`.
    ///
    /// This function takes a `GradientTemplateSize3` and converts it into a `MeshGradient`,
    /// using the template's size, points, and colors.
    ///
    /// - Parameter template: A `GradientTemplateSize3` containing the gradient's specifications.
    /// - Returns: A `MeshGradient` instance created from the provided template.
    ///
    /// Example:
    /// ```swift
    /// let gradient = MeshingKit.gradientSize3(template: .auroraBorealis)
    /// ```
    @MainActor public static func gradientSize3(template: GradientTemplateSize3)
        -> MeshGradient
    {
        gradient(template: template)
    }

    /// Creates a `MeshGradient` from a given `GradientTemplateSize2`.
    ///
    /// This function takes a `GradientTemplateSize2` and converts it into a `MeshGradient`,
    /// using the template's size, points, and colors.
    ///
    /// - Parameter template: A `GradientTemplateSize2` containing the gradient's specifications.
    /// - Returns: A `MeshGradient` instance created from the provided template.
    ///
    /// Example:
    /// ```swift
    /// let gradient = MeshingKit.gradientSize2(template: .mysticTwilight)
    /// ```
    @MainActor public static func gradientSize2(template: GradientTemplateSize2)
        -> MeshGradient
    {
        gradient(template: template)
    }

    /// Creates a `MeshGradient` from a given `GradientTemplateSize4`.
    ///
    /// This function takes a `GradientTemplateSize4` and converts it into a `MeshGradient`,
    /// using the template's size, points, and colors.
    ///
    /// - Parameter template: A `GradientTemplateSize4` containing the gradient's specifications.
    /// - Returns: A `MeshGradient` instance created from the provided template.
    ///
    /// Example:
    /// ```swift
    /// let gradient = MeshingKit.gradientSize4(template: .cosmicNebula)
    /// ```
    @MainActor public static func gradientSize4(template: GradientTemplateSize4)
        -> MeshGradient
    {
        gradient(template: template)
    }

    /// Creates a `MeshGradient` from a given `GradientTemplate`.
    ///
    /// This function takes any `GradientTemplate` and converts it into a `MeshGradient`,
    /// using the template's size, points, and colors.
    ///
    /// - Parameter template: A `GradientTemplate` containing the gradient's specifications.
    /// - Returns: A `MeshGradient` instance created from the provided template.
    ///
    /// Example:
    /// ```swift
    /// // Using with enum templates
    /// let gradient = MeshingKit.gradient(template: GradientTemplateSize3.auroraBorealis)
    ///
    /// // Using with custom template
    /// let customTemplate = CustomGradientTemplate(name: "Custom", size: 4,
    ///                                              points: [...], colors: [...], background: .black)
    /// let gradient = MeshingKit.gradient(template: customTemplate)
    /// ```
    @MainActor public static func gradient(template: GradientTemplate)
        -> MeshGradient
    {
        MeshGradient(
            width: template.size,
            height: template.size,
            locations: .points(template.points),
            colors: .colors(template.colors),
            background: template.background,
            smoothsColors: true
        )
    }

    /// Creates a `MeshGradient` from a predefined template.
    ///
    /// - Parameter template: The predefined template to use.
    /// - Returns: A `MeshGradient` instance created from the provided template.
    ///
    /// Example:
    /// ```swift
    /// let gradient = MeshingKit.gradient(template: .size3(.auroraBorealis))
    /// ```
    @MainActor public static func gradient(template: PredefinedTemplate)
        -> MeshGradient
    {
        switch template {
        case .size2(let template):
            return gradient(template: template)
        case .size3(let template):
            return gradient(template: template)
        case .size4(let template):
            return gradient(template: template)
        }
    }

    /// Creates an animated `MeshGradient` view from any gradient template.
    ///
    /// - Parameters:
    ///   - template: A gradient template to use.
    ///   - showAnimation: A binding to control the animation's play/pause state.
    ///   - animationSpeed: Controls the speed of the animation (default: 1.0).
    /// - Returns: A view containing the animated `MeshGradient`.
    ///
    /// Example:
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var showAnimation = true
    ///
    ///     var body: some View {
    ///         MeshingKit.animatedGradient(
    ///             .size3.intelligence,
    ///             showAnimation: $showAnimation,
    ///             animationSpeed: 1.5
    ///         )
    ///     }
    /// }
    /// ```
    @MainActor public static func animatedGradient(
        _ template: any GradientTemplate,
        showAnimation: Binding<Bool>,
        animationSpeed: Double = 1.0,
        animationPattern: AnimationPattern? = nil
    ) -> some View {
        AnimatedMeshGradientView(
            gridSize: template.size,
            showAnimation: showAnimation,
            positions: template.points,
            colors: template.colors,
            background: template.background,
            animationSpeed: animationSpeed,
            animationPattern: animationPattern
        )
    }

    /// Creates an animated `MeshGradient` view from a predefined template.
    ///
    /// - Parameters:
    ///   - template: A predefined template to use.
    ///   - showAnimation: A binding to control the animation's play/pause state.
    ///   - animationSpeed: Controls the speed of the animation (default: 1.0).
    /// - Returns: A view containing the animated `MeshGradient`.
    ///
    /// Example:
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var showAnimation = true
    ///
    ///     var body: some View {
    ///         MeshingKit.animatedGradient(
    ///             .size3(.intelligence),
    ///             showAnimation: $showAnimation,
    ///             animationSpeed: 1.5
    ///         )
    ///     }
    /// }
    /// ```
    @MainActor public static func animatedGradient(
        _ template: PredefinedTemplate,
        showAnimation: Binding<Bool>,
        animationSpeed: Double = 1.0,
        animationPattern: AnimationPattern? = nil
    ) -> some View {
        let baseTemplate: any GradientTemplate = switch template {
        case .size2(let specificTemplate): specificTemplate
        case .size3(let specificTemplate): specificTemplate
        case .size4(let specificTemplate): specificTemplate
        }

        return animatedGradient(
            baseTemplate,
            showAnimation: showAnimation,
            animationSpeed: animationSpeed,
            animationPattern: animationPattern
        )
    }
}
