//
//  GradientAnimation.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/21/25.
//

import SwiftUI

public extension MeshingKit {
    /// Generates animated positions for a given time phase.
    ///
    /// - Parameters:
    ///   - date: The time phase for animation (0.0 to 2π for a full cycle).
    ///   - positions: The base positions of the gradient points.
    ///   - animate: Whether to apply animation or return static positions.
    /// - Returns: An array of animated or static positions.
    static func animatedPositions(
        for date: Double,
        positions: [SIMD2<Float>],
        animate: Bool
    ) -> [SIMD2<Float>] {
        guard animate else {
            return positions
        }

        var animatedPositions = positions

        let count = positions.count
        if count > 4 && count < 16 {
            animatedPositions = animateMediumGrid(for: date, positions: animatedPositions)
        } else if count == 16 {
            animatedPositions = animateLargeGrid(for: date, positions: animatedPositions)
        }

        return animatedPositions
    }

    private static func animateMediumGrid(
        for date: Double,
        positions: [SIMD2<Float>]
    ) -> [SIMD2<Float>] {
        var animatedPositions = positions
        let phase = date

        animatedPositions[1].x = 0.5 + 0.4 * Float(cos(phase))
        animatedPositions[3].y = 0.5 + 0.3 * Float(cos(phase * 1.1))
        animatedPositions[4].y = 0.5 - 0.4 * Float(cos(phase * 0.9))
        animatedPositions[4].x = 0.5 + 0.2 * Float(cos(phase * 0.7))
        animatedPositions[5].y = 0.5 - 0.2 * Float(cos(phase * 0.9))
        animatedPositions[7].x = 0.5 - 0.4 * Float(cos(phase * 1.2))

        return animatedPositions
    }

    private static func animateLargeGrid(
        for date: Double,
        positions: [SIMD2<Float>]
    ) -> [SIMD2<Float>] {
        var animatedPositions = positions
        let phase = date / 2

        animatedPositions[1].x = 0.33 + 0.1 * Float(cos(phase * 0.7))
        animatedPositions[2].x = 0.67 - 0.1 * Float(cos(phase * 0.8))
        animatedPositions[4].y = 0.33 + 0.1 * Float(cos(phase * 0.9))
        animatedPositions[5].x = 0.33 + 0.15 * Float(cos(phase * 0.8))
        animatedPositions[5].y = 0.33 + 0.15 * Float(cos(phase * 0.9))
        animatedPositions[6].x = 0.67 - 0.15 * Float(cos(phase * 1.0))
        animatedPositions[6].y = 0.33 + 0.15 * Float(cos(phase * 1.1))
        animatedPositions[7].y = 0.37 - 0.1 * Float(cos(phase * 0.6))
        animatedPositions[9].x = 0.33 + 0.15 * Float(cos(phase * 1.2))
        animatedPositions[9].y = 0.67 - 0.15 * Float(cos(phase * 1.3))
        animatedPositions[10].x = 0.67 - 0.15 * Float(cos(phase * 1.4))
        animatedPositions[10].y = 0.67 - 0.15 * Float(cos(phase * 1.5))
        animatedPositions[11].y = 0.67 - 0.1 * Float(cos(phase * 1.2))
        animatedPositions[13].x = 0.33 + 0.1 * Float(cos(phase * 1.3))
        animatedPositions[14].x = 0.67 - 0.1 * Float(cos(phase * 1.4))

        return animatedPositions
    }
}
