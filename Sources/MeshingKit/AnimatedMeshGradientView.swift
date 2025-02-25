//
//  AnimatedMeshGradientView.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/19/24.
//

import SwiftUI

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
            .animation(minimumInterval: 1 / 120, paused: !showAnimation)
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
            var animatedPositions = positions.map {
                CGPoint(x: CGFloat($0.x), y: CGFloat($0.y))
            }

            animatedPositions[1].x = 0.5 + 0.4 * CGFloat(cos(phase))
            animatedPositions[3].y = 0.5 + 0.3 * CGFloat(cos(phase * 1.1))
            animatedPositions[4].y = 0.5 - 0.4 * CGFloat(cos(phase * 0.9))
            animatedPositions[4].x = 0.5 + 0.2 * CGFloat(cos(phase * 0.7))
            animatedPositions[5].y = 0.5 - 0.2 * CGFloat(cos(phase * 0.9))
            animatedPositions[7].x = 0.5 - 0.4 * CGFloat(cos(phase * 1.2))

            return animatedPositions.map {
                SIMD2<Float>(Float($0.x), Float($0.y))
            }
        } else if gridSize == 4 {
            let phase = adjustedTimeInterval / 2
            var animatedPositions = positions.map {
                CGPoint(x: CGFloat($0.x), y: CGFloat($0.y))
            }

            animatedPositions[1].x = 0.33 + 0.1 * CGFloat(cos(phase * 0.7))  // Top edge
            animatedPositions[2].x = 0.67 - 0.1 * CGFloat(cos(phase * 0.8))  // Top edge
            animatedPositions[4].y = 0.33 + 0.1 * CGFloat(cos(phase * 0.9))  // Left edge
            animatedPositions[7].y = 0.37 - 0.1 * CGFloat(cos(phase * 0.6))  // Left edge
            animatedPositions[11].y = 0.67 - 0.1 * CGFloat(cos(phase * 1.2))  // Bottom edge
            animatedPositions[13].x = 0.33 + 0.1 * CGFloat(cos(phase * 1.3))  // Right edge
            animatedPositions[14].x = 0.67 - 0.1 * CGFloat(cos(phase * 1.4))  // Right edge

            animatedPositions[5].x = 0.33 + 0.15 * CGFloat(cos(phase * 0.8))
            animatedPositions[5].y = 0.33 + 0.15 * CGFloat(cos(phase * 0.9))
            animatedPositions[6].x = 0.67 - 0.15 * CGFloat(cos(phase * 1.0))
            animatedPositions[6].y = 0.33 + 0.15 * CGFloat(cos(phase * 1.1))
            animatedPositions[9].x = 0.33 + 0.15 * CGFloat(cos(phase * 1.2))
            animatedPositions[9].y = 0.67 - 0.15 * CGFloat(cos(phase * 1.3))
            animatedPositions[10].x = 0.67 - 0.15 * CGFloat(cos(phase * 1.4))
            animatedPositions[10].y = 0.67 - 0.15 * CGFloat(cos(phase * 1.5))

            return animatedPositions.map {
                SIMD2<Float>(Float($0.x), Float($0.y))
            }
        } else {
            return positions
        }
    }
}
