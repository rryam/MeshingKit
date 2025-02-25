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
    /// let customTemplate = CustomTemplate() // implementing GradientTemplate protocol
    /// let gradient = MeshingKit.gradient(template: customTemplate)
    /// ```
    @MainActor public static func gradient(template: GradientTemplate)
        -> MeshGradient
    {
        MeshGradient(
            width: template.size, height: template.size,
            points: template.points, colors: template.colors)
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
    /// 
    /// Example:
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var showAnimation = true
    ///     
    ///     var body: some View {
    ///         MeshingKit.animatedGradientSize3(
    ///             template: .sunsetGlow, 
    ///             showAnimation: $showAnimation
    ///         )
    ///     }
    /// }
    /// ```
    @MainActor public static func animatedGradientSize3(
        template: GradientTemplateSize3, showAnimation: Binding<Bool>
    ) -> some View {
        animatedGradient(template: template, showAnimation: showAnimation)
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
    /// 
    /// Example:
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var showAnimation = true
    ///     
    ///     var body: some View {
    ///         MeshingKit.animatedGradientSize4(
    ///             template: .neonMetropolis, 
    ///             showAnimation: $showAnimation
    ///         )
    ///     }
    /// }
    /// ```
    @MainActor public static func animatedGradientSize4(
        template: GradientTemplateSize4, showAnimation: Binding<Bool>
    ) -> some View {
        animatedGradient(template: template, showAnimation: showAnimation)
    }

    /// Creates an animated `MeshGradient` view from a given `GradientTemplate`.
    ///
    /// This function takes any `GradientTemplate` and creates an animated `MeshGradient` view,
    /// using the template's size, points, colors, and background.
    ///
    /// - Parameters:
    ///   - template: A `GradientTemplate` containing the gradient's specifications.
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
    ///             template: GradientTemplateSize3.intelligence, 
    ///             showAnimation: $showAnimation,
    ///             animationSpeed: 1.5
    ///         )
    ///     }
    /// }
    /// ```
    @MainActor public static func animatedGradient(
        template: GradientTemplate,
        showAnimation: Binding<Bool>,
        animationSpeed: Double = 1.0
    ) -> some View {
        AnimatedMeshGradientView(
            gridSize: template.size,
            showAnimation: showAnimation,
            positions: template.points,
            colors: template.colors,
            background: template.background
        )
    }
}
