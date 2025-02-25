//
//  AnimationPattern.swift
//  MeshingKit
//
//  Created by Alex on \(Date().formatted(date: .numeric, time: .omitted))
//

import SwiftUI

/// Defines how a point's position should be animated over time.
public struct PointAnimation: Sendable {
    /// The index of the point in the gradient's position array.
    public let pointIndex: Int

    /// The axis to animate (x, y, or both).
    public let axis: Axis

    /// The amplitude of the animation (how far the point moves).
    public let amplitude: CGFloat

    /// The frequency multiplier (controls animation speed).
    public let frequency: CGFloat

    /// Possible axes for animation.
    public enum Axis: Sendable {
        case x, y, both
    }

    public init(
        pointIndex: Int, axis: Axis, amplitude: CGFloat,
        frequency: CGFloat = 1.0
    ) {
        self.pointIndex = pointIndex
        self.axis = axis
        self.amplitude = amplitude
        self.frequency = frequency
    }

    /// Applies the animation to a point based on the current phase.
    func apply(to point: inout CGPoint, at phase: Double) {
        let value = CGFloat(cos(phase * Double(frequency)))

        switch axis {
        case .x:
            point.x += amplitude * value
        case .y:
            point.y += amplitude * value
        case .both:
            point.x += amplitude * value
            point.y += amplitude * CGFloat(sin(phase * Double(frequency)))
        }
    }
}

/// A collection of point animations that can be applied to a mesh gradient.
public struct AnimationPattern: Sendable {
    /// The individual point animations in this pattern.
    public let animations: [PointAnimation]

    public init(animations: [PointAnimation]) {
        self.animations = animations
    }

    /// Creates a default animation pattern for a mesh gradient of the specified size.
    public static func defaultPattern(forGridSize size: Int) -> AnimationPattern
    {
        switch size {
        case 3:
            return AnimationPattern(animations: [
                PointAnimation(pointIndex: 1, axis: .x, amplitude: 0.4),
                PointAnimation(
                    pointIndex: 3, axis: .y, amplitude: 0.3, frequency: 1.1),
                PointAnimation(
                    pointIndex: 4, axis: .y, amplitude: -0.4, frequency: 0.9),
                PointAnimation(
                    pointIndex: 4, axis: .x, amplitude: 0.2, frequency: 0.7),
                PointAnimation(
                    pointIndex: 5, axis: .y, amplitude: -0.2, frequency: 0.9),
                PointAnimation(
                    pointIndex: 7, axis: .x, amplitude: -0.4, frequency: 1.2),
            ])
        case 4:
            return AnimationPattern(animations: [
                // Edge points
                PointAnimation(
                    pointIndex: 1, axis: .x, amplitude: 0.1, frequency: 0.7),
                PointAnimation(
                    pointIndex: 2, axis: .x, amplitude: -0.1, frequency: 0.8),
                PointAnimation(
                    pointIndex: 4, axis: .y, amplitude: 0.1, frequency: 0.9),
                PointAnimation(
                    pointIndex: 7, axis: .y, amplitude: -0.1, frequency: 0.6),
                PointAnimation(
                    pointIndex: 11, axis: .y, amplitude: -0.1, frequency: 1.2),
                PointAnimation(
                    pointIndex: 13, axis: .x, amplitude: 0.1, frequency: 1.3),
                PointAnimation(
                    pointIndex: 14, axis: .x, amplitude: -0.1, frequency: 1.4),

                // Inner points
                PointAnimation(
                    pointIndex: 5, axis: .both, amplitude: 0.15, frequency: 0.8),
                PointAnimation(
                    pointIndex: 6, axis: .both, amplitude: -0.15, frequency: 1.0
                ),
                PointAnimation(
                    pointIndex: 9, axis: .both, amplitude: 0.15, frequency: 1.2),
                PointAnimation(
                    pointIndex: 10, axis: .both, amplitude: -0.15,
                    frequency: 1.4),
            ])
        default:
            return AnimationPattern(animations: [])
        }
    }

    /// Applies all animations in the pattern to the points.
    func apply(to points: [CGPoint], at phase: Double) -> [CGPoint] {
        var result = points

        for animation in animations {
            let index = animation.pointIndex
            guard index < result.count else { continue }

            animation.apply(to: &result[index], at: phase)
        }

        return result
    }
}
