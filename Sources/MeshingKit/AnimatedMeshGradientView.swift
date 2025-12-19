//
//  AnimatedMeshGradientView.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/19/24.
//

import SwiftUI
import simd

/// Animation constants for mesh gradient animations.
private enum AnimationConstants {
    /// Animation frame rate (frames per second).
    static let frameRate: Double = 120

    // Grid size 3 animation constants
    enum GridSize3 {
        static let centerX: Float = 0.5
        static let centerY: Float = 0.5
        static let amplitude1: Float = 0.4
        static let amplitude2: Float = 0.3
        static let amplitude3: Float = 0.2
        static let frequency1: Double = 1.0
        static let frequency2: Double = 1.1
        static let frequency3: Double = 0.9
        static let frequency4: Double = 0.7
        static let frequency5: Double = 1.2
    }

    // Grid size 4 animation constants
    enum GridSize4 {
        static let phaseDivider: Double = 2.0
        static let position1: Float = 0.33
        static let position2: Float = 0.67
        static let position3: Float = 0.37
        static let edgeAmplitude: Float = 0.1
        static let innerAmplitude: Float = 0.15
        static let frequency1: Double = 0.7
        static let frequency2: Double = 0.8
        static let frequency3: Double = 0.9
        static let frequency4: Double = 0.6
        static let frequency5: Double = 1.2
        static let frequency6: Double = 1.3
        static let frequency7: Double = 1.4
        static let frequency8: Double = 1.5
        static let frequency9: Double = 1.0
        static let frequency10: Double = 1.1
    }
}

/// A view that displays an animated mesh gradient.
public struct AnimatedMeshGradientView: View {
    /// The size of the gradient grid (e.g., 3 for a 3x3 grid).
    var gridSize: Int

    /// A binding that controls whether the animation is currently playing.
    @Binding var showAnimation: Bool

    /// An array of 2D points that define the control points of the gradient.
    ///
    /// Each point is represented as a `SIMD2<Float>` where coordinates range from 0.0 to 1.0.
    var positions: [SIMD2<Float>]

    /// An array of colors associated with the control points.
    ///
    /// The colors in this array correspond to the points in the `positions` array.
    var colors: [Color]

    /// The background color of the gradient.
    ///
    /// This color is used as the base color for areas not directly affected by the control points.
    var background: Color

    /// The speed multiplier for the animation.
    ///
    /// A value of 1.0 represents normal speed, 2.0 is twice as fast, and 0.5 is half speed.
    var animationSpeed: Double

    /// Optional animation pattern for point-based animations.
    ///
    /// When provided, this pattern is applied to `positions` each frame.
    var animationPattern: AnimationPattern?

    /// Whether the gradient should smooth between colors.
    ///
    /// Defaults to `true` for softer transitions.
    var smoothsColors: Bool

    /// Creates a new animated mesh gradient view with the specified parameters.
    ///
    /// - Parameters:
    ///   - gridSize: The size of the gradient grid (e.g., 3 for a 3x3 grid).
    ///   - showAnimation: A binding that controls whether the animation is currently playing.
    ///   - positions: An array of 2D points that define the control points of the gradient.
    ///   - colors: An array of colors associated with the control points.
    ///   - background: The background color of the gradient.
    ///   - animationSpeed: The speed multiplier for the animation (default: 1.0).
    ///   - animationPattern: Optional custom animation pattern to apply.
    ///   - smoothsColors: Whether the gradient should smooth between colors (default: `true`).
    public init(
        gridSize: Int,
        showAnimation: Binding<Bool>,
        positions: [SIMD2<Float>],
        colors: [Color],
        background: Color,
        animationSpeed: Double = 1.0,
        animationPattern: AnimationPattern? = nil,
        smoothsColors: Bool = true
    ) {
        self.gridSize = gridSize
        self._showAnimation = showAnimation
        self.positions = positions
        self.colors = colors
        self.background = background
        self.animationSpeed = animationSpeed
        self.animationPattern = animationPattern
        self.smoothsColors = smoothsColors
    }

    /// The body of the view, displaying an animated mesh gradient.
    public var body: some View {
        TimelineView(
            .animation(minimumInterval: 1 / AnimationConstants.frameRate, paused: !showAnimation)
        ) { phase in
            MeshGradient(
                width: gridSize,
                height: gridSize,
                locations: .points(animatedPositions(for: phase.date)),
                colors: .colors(colors),
                background: background,
                smoothsColors: smoothsColors
            )
            .ignoresSafeArea()
        }
    }

    private func animatedPositions(for date: Date) -> [SIMD2<Float>] {
        let adjustedTimeInterval =
            date.timeIntervalSinceReferenceDate * animationSpeed

        if let animationPattern, gridSize >= 3 {
            let animated = animationPattern.apply(to: positions, at: adjustedTimeInterval)
            return clampedToUnitSquare(animated)
        }

        switch gridSize {
        case 3:
            return animatedPositionsForGridSize3(
                phase: adjustedTimeInterval, positions: positions)
        case 4:
            return animatedPositionsForGridSize4(
                phase: adjustedTimeInterval, positions: positions)
        default:
            return positions
        }
    }

    private func animatedPositionsForGridSize3(
        phase: Double, positions: [SIMD2<Float>]
    ) -> [SIMD2<Float>] {
        guard positions.count >= 9 else { return positions }
        var animatedPositions = positions

        animatedPositions[1].x = AnimationConstants.GridSize3.centerX
            + AnimationConstants.GridSize3.amplitude1
            * Float(cos(phase * AnimationConstants.GridSize3.frequency1))
        animatedPositions[3].y = AnimationConstants.GridSize3.centerY
            + AnimationConstants.GridSize3.amplitude2
            * Float(cos(phase * AnimationConstants.GridSize3.frequency2))
        animatedPositions[4].y = AnimationConstants.GridSize3.centerY
            - AnimationConstants.GridSize3.amplitude1
            * Float(cos(phase * AnimationConstants.GridSize3.frequency3))
        animatedPositions[4].x = AnimationConstants.GridSize3.centerX
            + AnimationConstants.GridSize3.amplitude3
            * Float(cos(phase * AnimationConstants.GridSize3.frequency4))
        animatedPositions[5].y = AnimationConstants.GridSize3.centerY
            - AnimationConstants.GridSize3.amplitude3
            * Float(cos(phase * AnimationConstants.GridSize3.frequency3))
        animatedPositions[7].x = AnimationConstants.GridSize3.centerX
            - AnimationConstants.GridSize3.amplitude1
            * Float(cos(phase * AnimationConstants.GridSize3.frequency5))

        return animatedPositions
    }

    private func animatedPositionsForGridSize4(
        phase: Double, positions: [SIMD2<Float>]
    ) -> [SIMD2<Float>] {
        guard positions.count >= 16 else { return positions }
        let adjustedPhase = phase / AnimationConstants.GridSize4.phaseDivider
        var animatedPositions = positions

        animateGridSize4Edges(&animatedPositions, phase: adjustedPhase)
        animateGridSize4InnerPoints(&animatedPositions, phase: adjustedPhase)

        return animatedPositions
    }

    private func animateGridSize4Edges(
        _ positions: inout [SIMD2<Float>], phase: Double
    ) {
        // Top edge
        positions[1].x = AnimationConstants.GridSize4.position1
            + AnimationConstants.GridSize4.edgeAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency1))
        positions[2].x = AnimationConstants.GridSize4.position2
            - AnimationConstants.GridSize4.edgeAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency2))
        // Left edge
        positions[4].y = AnimationConstants.GridSize4.position1
            + AnimationConstants.GridSize4.edgeAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency3))
        positions[7].y = AnimationConstants.GridSize4.position3
            - AnimationConstants.GridSize4.edgeAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency4))
        // Bottom edge
        positions[11].y = AnimationConstants.GridSize4.position2
            - AnimationConstants.GridSize4.edgeAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency5))
        // Right edge
        positions[13].x = AnimationConstants.GridSize4.position1
            + AnimationConstants.GridSize4.edgeAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency6))
        positions[14].x = AnimationConstants.GridSize4.position2
            - AnimationConstants.GridSize4.edgeAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency7))
    }

    private func animateGridSize4InnerPoints(
        _ positions: inout [SIMD2<Float>], phase: Double
    ) {
        positions[5].x = AnimationConstants.GridSize4.position1
            + AnimationConstants.GridSize4.innerAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency2))
        positions[5].y = AnimationConstants.GridSize4.position1
            + AnimationConstants.GridSize4.innerAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency3))
        positions[6].x = AnimationConstants.GridSize4.position2
            - AnimationConstants.GridSize4.innerAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency9))
        positions[6].y = AnimationConstants.GridSize4.position1
            + AnimationConstants.GridSize4.innerAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency10))
        positions[9].x = AnimationConstants.GridSize4.position1
            + AnimationConstants.GridSize4.innerAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency5))
        positions[9].y = AnimationConstants.GridSize4.position2
            - AnimationConstants.GridSize4.innerAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency6))
        positions[10].x = AnimationConstants.GridSize4.position2
            - AnimationConstants.GridSize4.innerAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency7))
        positions[10].y = AnimationConstants.GridSize4.position2
            - AnimationConstants.GridSize4.innerAmplitude
            * Float(cos(phase * AnimationConstants.GridSize4.frequency8))
    }

    private func clampedToUnitSquare(_ positions: [SIMD2<Float>]) -> [SIMD2<Float>] {
        let lowerBound = SIMD2<Float>.zero
        let upperBound = SIMD2<Float>(repeating: 1.0)
        return positions.map { point in
            simd_clamp(point, lowerBound, upperBound)
        }
    }
}
