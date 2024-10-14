//
//  GradientTemplateSize4.swift
//  MeshingKit
//
//  Created by Assistant on 3/22/2024.
//

import SwiftUI

/// An enumeration of predefined gradient templates with a 4x4 grid size.
public enum GradientTemplateSize4: String, CaseIterable {
  case auroraBorealis
  case sunsetHorizon
  case mysticForest
  case cosmicNebula
  case coralReef
  case etherealTwilight
  case volcanicOasis
  case arcticFrost
  case jungleMist
  case desertMirage
  case neonMetropolis

  /// The name of the gradient template.
  public var name: String {
    rawValue.capitalized
  }

  /// The size of the gradient, representing both width and height in pixels.
  public var size: Int {
    4
  }

  /// An array of 2D points that define the control points of the gradient.
  public var points: [SIMD2<Float>] {
    switch self {
      case .auroraBorealis:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.263, y: 0.000), .init(x: 0.680, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.244), .init(x: 0.565, y: 0.340), .init(x: 0.815, y: 0.689), .init(x: 1.000, y: 0.147),
          .init(x: 0.000, y: 0.715), .init(x: 0.289, y: 0.418), .init(x: 0.594, y: 0.766), .init(x: 1.000, y: 0.650),
          .init(x: 0.000, y: 1.000), .init(x: 0.244, y: 1.000), .init(x: 0.672, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .sunsetHorizon:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.300, y: 0.000), .init(x: 0.700, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.250), .init(x: 0.352, y: 0.641), .init(x: 0.609, y: 0.131), .init(x: 1.000, y: 0.200),
          .init(x: 0.000, y: 0.700), .init(x: 0.584, y: 0.764), .init(x: 0.790, y: 0.210), .init(x: 1.000, y: 0.750),
          .init(x: 0.000, y: 1.000), .init(x: 0.300, y: 1.000), .init(x: 0.700, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .mysticForest:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.350, y: 0.000), .init(x: 0.650, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.400), .init(x: 0.181, y: 0.471), .init(x: 0.882, y: 0.225), .init(x: 1.000, y: 0.300),
          .init(x: 0.000, y: 0.600), .init(x: 0.290, y: 0.546), .init(x: 0.634, y: 0.238), .init(x: 1.000, y: 0.861),
          .init(x: 0.000, y: 1.000), .init(x: 0.350, y: 1.000), .init(x: 0.650, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .cosmicNebula:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.200, y: 0.000), .init(x: 0.800, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.447), .init(x: 0.253, y: 0.317), .init(x: 0.300, y: 0.175), .init(x: 1.000, y: 0.404),
          .init(x: 0.000, y: 0.520), .init(x: 0.459, y: 0.666), .init(x: 0.741, y: 0.429), .init(x: 1.000, y: 0.784),
          .init(x: 0.000, y: 1.000), .init(x: 0.465, y: 1.000), .init(x: 0.616, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .coralReef:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.400, y: 0.000), .init(x: 0.600, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.300), .init(x: 0.708, y: 0.589), .init(x: 0.844, y: 0.343), .init(x: 1.000, y: 0.400),
          .init(x: 0.000, y: 0.700), .init(x: 0.232, y: 0.362), .init(x: 0.716, y: 0.892), .init(x: 1.000, y: 0.600),
          .init(x: 0.000, y: 1.000), .init(x: 0.400, y: 1.000), .init(x: 0.600, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .etherealTwilight:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.333, y: 0.000), .init(x: 0.667, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.333), .init(x: 0.421, y: 0.512), .init(x: 0.739, y: 0.187), .init(x: 1.000, y: 0.333),
          .init(x: 0.000, y: 0.667), .init(x: 0.176, y: 0.845), .init(x: 0.623, y: 0.401), .init(x: 1.000, y: 0.667),
          .init(x: 0.000, y: 1.000), .init(x: 0.333, y: 1.000), .init(x: 0.667, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .volcanicOasis:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.333, y: 0.000), .init(x: 0.667, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.333), .init(x: 0.218, y: 0.456), .init(x: 0.789, y: 0.123), .init(x: 1.000, y: 0.333),
          .init(x: 0.000, y: 0.667), .init(x: 0.567, y: 0.901), .init(x: 0.345, y: 0.234), .init(x: 1.000, y: 0.667),
          .init(x: 0.000, y: 1.000), .init(x: 0.333, y: 1.000), .init(x: 0.667, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .arcticFrost:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.333, y: 0.000), .init(x: 0.667, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.333), .init(x: 0.678, y: 0.543), .init(x: 0.234, y: 0.876), .init(x: 1.000, y: 0.333),
          .init(x: 0.000, y: 0.667), .init(x: 0.432, y: 0.321), .init(x: 0.901, y: 0.765), .init(x: 1.000, y: 0.667),
          .init(x: 0.000, y: 1.000), .init(x: 0.333, y: 1.000), .init(x: 0.667, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .jungleMist:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.333, y: 0.000), .init(x: 0.667, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.333), .init(x: 0.123, y: 0.789), .init(x: 0.876, y: 0.432), .init(x: 1.000, y: 0.333),
          .init(x: 0.000, y: 0.667), .init(x: 0.654, y: 0.210), .init(x: 0.345, y: 0.678), .init(x: 1.000, y: 0.667),
          .init(x: 0.000, y: 1.000), .init(x: 0.333, y: 1.000), .init(x: 0.667, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .desertMirage:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.333, y: 0.000), .init(x: 0.667, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.333), .init(x: 0.789, y: 0.234), .init(x: 0.456, y: 0.901), .init(x: 1.000, y: 0.333),
          .init(x: 0.000, y: 0.667), .init(x: 0.321, y: 0.567), .init(x: 0.765, y: 0.123), .init(x: 1.000, y: 0.667),
          .init(x: 0.000, y: 1.000), .init(x: 0.333, y: 1.000), .init(x: 0.667, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
      case .neonMetropolis:
        return [
          .init(x: 0.000, y: 0.000), .init(x: 0.333, y: 0.000), .init(x: 0.667, y: 0.000), .init(x: 1.000, y: 0.000),
          .init(x: 0.000, y: 0.333), .init(x: 0.543, y: 0.210), .init(x: 0.876, y: 0.789), .init(x: 1.000, y: 0.333),
          .init(x: 0.000, y: 0.667), .init(x: 0.234, y: 0.678), .init(x: 0.765, y: 0.345), .init(x: 1.000, y: 0.667),
          .init(x: 0.000, y: 1.000), .init(x: 0.333, y: 1.000), .init(x: 0.667, y: 1.000), .init(x: 1.000, y: 1.000)
        ]
    }
  }

  /// An array of colors associated with the control points.
  public var colors: [Color] {
    switch self {
      case .auroraBorealis:
        return [
          Color(hex: "#00264d"), Color(hex: "#004080"), Color(hex: "#0059b3"), Color(hex: "#0073e6"),
          Color(hex: "#1a8cff"), Color(hex: "#4da6ff"), Color(hex: "#80bfff"), Color(hex: "#b3d9ff"),
          Color(hex: "#00ff80"), Color(hex: "#33ff99"), Color(hex: "#66ffb3"), Color(hex: "#99ffcc"),
          Color(hex: "#004d40"), Color(hex: "#00665c"), Color(hex: "#008577"), Color(hex: "#00a693")
        ]
      case .sunsetHorizon:
        return [
          Color(hex: "#ff6600"), Color(hex: "#ff8533"), Color(hex: "#ffa366"), Color(hex: "#ffc199"),
          Color(hex: "#ffb3ba"), Color(hex: "#ff99a7"), Color(hex: "#ff8093"), Color(hex: "#ff6680"),
          Color(hex: "#ff4d6a"), Color(hex: "#ff3357"), Color(hex: "#ff1a44"), Color(hex: "#ff0030"),
          Color(hex: "#cc0026"), Color(hex: "#990026"), Color(hex: "#660026"), Color(hex: "#330026")
        ]
      case .mysticForest:
        return [
          Color(hex: "#004d00"), Color(hex: "#006600"), Color(hex: "#008000"), Color(hex: "#009900"),
          Color(hex: "#00b300"), Color(hex: "#00cc00"), Color(hex: "#00e600"), Color(hex: "#00ff00"),
          Color(hex: "#33ff33"), Color(hex: "#66ff66"), Color(hex: "#99ff99"), Color(hex: "#ccffcc"),
          Color(hex: "#004000"), Color(hex: "#005900"), Color(hex: "#007300"), Color(hex: "#008c00")
        ]
      case .cosmicNebula:
        return [
          Color(hex: "#1a1a33"), Color(hex: "#33334d"), Color(hex: "#4d4d66"), Color(hex: "#666680"),
          Color(hex: "#8080b3"), Color(hex: "#9999cc"), Color(hex: "#b3b3e6"), Color(hex: "#ccccff"),
          Color(hex: "#ff99ff"), Color(hex: "#ff66ff"), Color(hex: "#ff33ff"), Color(hex: "#ff00ff"),
          Color(hex: "#cc00cc"), Color(hex: "#990099"), Color(hex: "#660066"), Color(hex: "#330033")
        ]
      case .coralReef:
        return [
          Color(hex: "#004d66"), Color(hex: "#006680"), Color(hex: "#008099"), Color(hex: "#0099b3"),
          Color(hex: "#00b3cc"), Color(hex: "#00cce6"), Color(hex: "#00e6ff"), Color(hex: "#1affff"),
          Color(hex: "#ff6666"), Color(hex: "#ff8080"), Color(hex: "#ff9999"), Color(hex: "#ffb3b3"),
          Color(hex: "#ffcc00"), Color(hex: "#ffe600"), Color(hex: "#ffff1a"), Color(hex: "#ffff4d")
        ]
      case .etherealTwilight:
        return [
          Color(hex: "#2e0059"), Color(hex: "#420080"), Color(hex: "#5600a6"), Color(hex: "#6a00cc"),
          Color(hex: "#7f00f2"), Color(hex: "#9933ff"), Color(hex: "#b366ff"), Color(hex: "#cc99ff"),
          Color(hex: "#ff66b3"), Color(hex: "#ff99cc"), Color(hex: "#ffcce6"), Color(hex: "#fff0f5"),
          Color(hex: "#ff3300"), Color(hex: "#ff6600"), Color(hex: "#ff9900"), Color(hex: "#ffcc00")
        ]
      case .volcanicOasis:
        return [
          Color(hex: "#660000"), Color(hex: "#990000"), Color(hex: "#cc0000"), Color(hex: "#ff0000"),
          Color(hex: "#ff3300"), Color(hex: "#ff6600"), Color(hex: "#ff9900"), Color(hex: "#ffcc00"),
          Color(hex: "#00cc66"), Color(hex: "#00e677"), Color(hex: "#00ff88"), Color(hex: "#66ffb3"),
          Color(hex: "#003366"), Color(hex: "#004080"), Color(hex: "#004d99"), Color(hex: "#0059b3")
        ]
      case .arcticFrost:
        return [
          Color(hex: "#ffffff"), Color(hex: "#f0f8ff"), Color(hex: "#e6f2ff"), Color(hex: "#ccebff"),
          Color(hex: "#b3e0ff"), Color(hex: "#99d6ff"), Color(hex: "#80ccff"), Color(hex: "#66c2ff"),
          Color(hex: "#4db8ff"), Color(hex: "#33adff"), Color(hex: "#1aa3ff"), Color(hex: "#0099ff"),
          Color(hex: "#0080d6"), Color(hex: "#0066cc"), Color(hex: "#004db3"), Color(hex: "#003399")
        ]
      case .jungleMist:
        return [
          Color(hex: "#264d00"), Color(hex: "#336600"), Color(hex: "#408000"), Color(hex: "#4d9900"),
          Color(hex: "#59b300"), Color(hex: "#66cc00"), Color(hex: "#73e600"), Color(hex: "#80ff00"),
          Color(hex: "#b3ff66"), Color(hex: "#ccff99"), Color(hex: "#e6ffcc"), Color(hex: "#f2fff2"),
          Color(hex: "#006666"), Color(hex: "#008080"), Color(hex: "#009999"), Color(hex: "#00b3b3")
        ]
      case .desertMirage:
        return [
          Color(hex: "#fff2d9"), Color(hex: "#ffedcc"), Color(hex: "#ffe6b3"), Color(hex: "#ffdf99"),
          Color(hex: "#ffd480"), Color(hex: "#ffcc66"), Color(hex: "#ffc34d"), Color(hex: "#ffbb33"),
          Color(hex: "#ff9900"), Color(hex: "#ff8000"), Color(hex: "#ff6600"), Color(hex: "#ff4d00"),
          Color(hex: "#ff3300"), Color(hex: "#ff1a00"), Color(hex: "#ff0000"), Color(hex: "#cc0000")
        ]
      case .neonMetropolis:
        return [
          Color(hex: "#1a0033"), Color(hex: "#330066"), Color(hex: "#4d0099"), Color(hex: "#6600cc"),
          Color(hex: "#8000ff"), Color(hex: "#9933ff"), Color(hex: "#b366ff"), Color(hex: "#cc99ff"),
          Color(hex: "#00ff00"), Color(hex: "#33ff33"), Color(hex: "#66ff66"), Color(hex: "#99ff99"),
          Color(hex: "#ff0066"), Color(hex: "#ff3399"), Color(hex: "#ff66cc"), Color(hex: "#ff99ff")
        ]
    }
  }

  /// The background color of the gradient.
  public var background: Color {
    switch self {
      case .auroraBorealis:
        return Color(hex: "#001a33")
      case .sunsetHorizon:
        return Color(hex: "#660000")
      case .mysticForest:
        return Color(hex: "#002600")
      case .cosmicNebula:
        return Color(hex: "#0d0d1a")
      case .coralReef:
        return Color(hex: "#00334d")
      case .etherealTwilight:
        return Color(hex: "#1a0033")
      case .volcanicOasis:
        return Color(hex: "#330000")
      case .arcticFrost:
        return Color(hex: "#e6f3ff")
      case .jungleMist:
        return Color(hex: "#1a3300")
      case .desertMirage:
        return Color(hex: "#ffe6b3")
      case .neonMetropolis:
        return Color(hex: "#000000")
    }
  }
}
