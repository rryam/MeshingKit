// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct MeshingKit {
    public static func gradient(template: GradientTemplate) -> MeshGradient {
        MeshGradient(width: template.size, height: template.size, points: template.points, colors: template.colors)
    }
}
