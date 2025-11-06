//
//  AnimatedMeshGradientView.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/19/24.
//

import SwiftUI

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
    var gridSize: Int
    @Binding var showAnimation: Bool
    var positions: [SIMD2<Float>]
    var colors: [Color]
    var background: Color
    var animationSpeed: Double

    public init(
        gridSize: Int,
        showAnimation: Binding<Bool>,
        positions: [SIMD2<Float>],
        colors: [Color],
        background: Color,
        animationSpeed: Double = 1.0
    ) {
        self.gridSize = gridSize
        self._showAnimation = showAnimation
        self.positions = positions
        self.colors = colors
        self.background = background
        self.animationSpeed = animationSpeed
    }

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
                smoothsColors: true
            )
            .ignoresSafeArea()
        }
    }

    private func animatedPositions(for date: Date) -> [SIMD2<Float>] {
        let adjustedTimeInterval =
            date.timeIntervalSinceReferenceDate * animationSpeed

        if gridSize == 3 {
            let phase = adjustedTimeInterval
            var animatedPositions = positions

            animatedPositions[1].x = AnimationConstants.GridSize3.centerX + AnimationConstants.GridSize3.amplitude1 * Float(cos(phase * AnimationConstants.GridSize3.frequency1))
            animatedPositions[3].y = AnimationConstants.GridSize3.centerY + AnimationConstants.GridSize3.amplitude2 * Float(cos(phase * AnimationConstants.GridSize3.frequency2))
            animatedPositions[4].y = AnimationConstants.GridSize3.centerY - AnimationConstants.GridSize3.amplitude1 * Float(cos(phase * AnimationConstants.GridSize3.frequency3))
            animatedPositions[4].x = AnimationConstants.GridSize3.centerX + AnimationConstants.GridSize3.amplitude3 * Float(cos(phase * AnimationConstants.GridSize3.frequency4))
            animatedPositions[5].y = AnimationConstants.GridSize3.centerY - AnimationConstants.GridSize3.amplitude3 * Float(cos(phase * AnimationConstants.GridSize3.frequency3))
            animatedPositions[7].x = AnimationConstants.GridSize3.centerX - AnimationConstants.GridSize3.amplitude1 * Float(cos(phase * AnimationConstants.GridSize3.frequency5))

            return animatedPositions
        } else if gridSize == 4 {
            let phase = adjustedTimeInterval / AnimationConstants.GridSize4.phaseDivider
            var animatedPositions = positions

            animatedPositions[1].x = AnimationConstants.GridSize4.position1 + AnimationConstants.GridSize4.edgeAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency1))  // Top edge
            animatedPositions[2].x = AnimationConstants.GridSize4.position2 - AnimationConstants.GridSize4.edgeAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency2))  // Top edge
            animatedPositions[4].y = AnimationConstants.GridSize4.position1 + AnimationConstants.GridSize4.edgeAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency3))  // Left edge
            animatedPositions[7].y = AnimationConstants.GridSize4.position3 - AnimationConstants.GridSize4.edgeAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency4))  // Left edge
            animatedPositions[11].y = AnimationConstants.GridSize4.position2 - AnimationConstants.GridSize4.edgeAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency5))  // Bottom edge
            animatedPositions[13].x = AnimationConstants.GridSize4.position1 + AnimationConstants.GridSize4.edgeAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency6))  // Right edge
            animatedPositions[14].x = AnimationConstants.GridSize4.position2 - AnimationConstants.GridSize4.edgeAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency7))  // Right edge

            animatedPositions[5].x = AnimationConstants.GridSize4.position1 + AnimationConstants.GridSize4.innerAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency2))
            animatedPositions[5].y = AnimationConstants.GridSize4.position1 + AnimationConstants.GridSize4.innerAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency3))
            animatedPositions[6].x = AnimationConstants.GridSize4.position2 - AnimationConstants.GridSize4.innerAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency9))
            animatedPositions[6].y = AnimationConstants.GridSize4.position1 + AnimationConstants.GridSize4.innerAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency10))
            animatedPositions[9].x = AnimationConstants.GridSize4.position1 + AnimationConstants.GridSize4.innerAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency5))
            animatedPositions[9].y = AnimationConstants.GridSize4.position2 - AnimationConstants.GridSize4.innerAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency6))
            animatedPositions[10].x = AnimationConstants.GridSize4.position2 - AnimationConstants.GridSize4.innerAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency7))
            animatedPositions[10].y = AnimationConstants.GridSize4.position2 - AnimationConstants.GridSize4.innerAmplitude * Float(cos(phase * AnimationConstants.GridSize4.frequency8))

            return animatedPositions
        } else {
            return positions
        }
    }
}
