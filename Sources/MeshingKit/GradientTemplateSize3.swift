//
//  GradientTemplateSize3.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/14/24.
//

import SwiftUI

/// An enumeration of predefined gradient templates with a 3x3 grid size.
public enum GradientTemplateSize3: String, CaseIterable {
    case intelligence
    case auroraBorealis
    case sunsetGlow
    case oceanDepths
    case neonNight
    case autumnLeaves
    case cosmicAurora
    case lavaFlow
    case etherealMist
    case tropicalParadise
    case midnightGalaxy
    case desertMirage
    case frostedCrystal
    case enchantedForest
    case rubyFusion
    case goldenSunrise
    case cosmicNebula
    case arcticAurora
    case volcanicEmber
    case mintBreeze
    case twilightSerenade
    case saharaDunes

    /// The name of the gradient template.
    public var name: String {
        rawValue.capitalized
    }

    /// The size of the gradient, representing both width and height in pixels.
    public var size: Int {
        3
    }

    /// An array of 2D points that define the control points of the gradient.
    public var points: [SIMD2<Float>] {
        switch self {
        case .intelligence:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.400, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.450), .init(x: 0.653, y: 0.670),
                .init(x: 1.000, y: 0.200),
                .init(x: 0.000, y: 1.000), .init(x: 0.550, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .auroraBorealis:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.400, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.450), .init(x: 0.900, y: 0.700),
                .init(x: 1.000, y: 0.200),
                .init(x: 0.000, y: 1.000), .init(x: 0.550, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .sunsetGlow:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.100, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.537), .init(x: 0.182, y: 0.794),
                .init(x: 1.000, y: 0.148),
                .init(x: 0.000, y: 1.000), .init(x: 0.900, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .oceanDepths:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.497, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.213), .init(x: 0.670, y: 0.930),
                .init(x: 1.000, y: 0.091),
                .init(x: 0.000, y: 1.000), .init(x: 0.490, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .neonNight:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.200, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.596), .init(x: 0.807, y: 0.295),
                .init(x: 1.000, y: 0.200),
                .init(x: 0.000, y: 1.000), .init(x: 0.800, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .autumnLeaves:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.300, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.700), .init(x: 0.172, y: 0.154),
                .init(x: 1.000, y: 0.300),
                .init(x: 0.000, y: 1.000), .init(x: 0.700, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .cosmicAurora:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.161, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.326), .init(x: 0.263, y: 0.882),
                .init(x: 1.003, y: 0.142),
                .init(x: 0.000, y: 1.000), .init(x: 0.600, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .lavaFlow:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.737, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.177), .init(x: 0.703, y: 0.809),
                .init(x: 1.000, y: 0.503),
                .init(x: 0.000, y: 1.000), .init(x: 0.502, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .etherealMist:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.850, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.150), .init(x: 0.920, y: 0.080),
                .init(x: 1.000, y: 0.850),
                .init(x: 0.000, y: 1.000), .init(x: 0.150, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .tropicalParadise:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.400, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.600), .init(x: 0.250, y: 0.750),
                .init(x: 1.000, y: 0.400),
                .init(x: 0.000, y: 1.000), .init(x: 0.950, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .midnightGalaxy:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.100, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.900), .init(x: 0.800, y: 0.200),
                .init(x: 1.000, y: 0.100),
                .init(x: 0.000, y: 1.000), .init(x: 0.900, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .desertMirage:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.300, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.700), .init(x: 0.600, y: 0.400),
                .init(x: 1.000, y: 0.300),
                .init(x: 0.000, y: 1.000), .init(x: 0.700, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .frostedCrystal:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.400, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.600), .init(x: 0.200, y: 0.200),
                .init(x: 1.000, y: 0.400),
                .init(x: 0.000, y: 1.000), .init(x: 0.600, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .enchantedForest:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.300, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.700), .init(x: 0.500, y: 0.300),
                .init(x: 1.000, y: 0.300),
                .init(x: 0.000, y: 1.000), .init(x: 0.700, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .rubyFusion:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.200, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.800), .init(x: 0.400, y: 0.600),
                .init(x: 1.000, y: 0.200),
                .init(x: 0.000, y: 1.000), .init(x: 0.800, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .goldenSunrise:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.600, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.400), .init(x: 0.700, y: 0.300),
                .init(x: 1.000, y: 0.600),
                .init(x: 0.000, y: 1.000), .init(x: 0.400, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .cosmicNebula:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.500, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.500), .init(x: 0.750, y: 0.250),
                .init(x: 1.000, y: 0.500),
                .init(x: 0.000, y: 1.000), .init(x: 0.500, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .arcticAurora:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.300, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.700), .init(x: 0.600, y: 0.400),
                .init(x: 1.000, y: 0.300),
                .init(x: 0.000, y: 1.000), .init(x: 0.700, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .volcanicEmber:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.200, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.800), .init(x: 0.500, y: 0.500),
                .init(x: 1.000, y: 0.200),
                .init(x: 0.000, y: 1.000), .init(x: 0.800, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .mintBreeze:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.400, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.600), .init(x: 0.720, y: 0.860),
                .init(x: 1.000, y: 0.130),
                .init(x: 0.000, y: 1.000), .init(x: 0.600, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .twilightSerenade:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.300, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.230), .init(x: 0.220, y: 0.770),
                .init(x: 1.000, y: 0.210),
                .init(x: 0.000, y: 1.000), .init(x: 0.700, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        case .saharaDunes:
            return [
                .init(x: 0.000, y: 0.000), .init(x: 0.400, y: 0.000),
                .init(x: 1.000, y: 0.000),
                .init(x: 0.000, y: 0.600), .init(x: 0.700, y: 0.300),
                .init(x: 1.000, y: 0.400),
                .init(x: 0.000, y: 1.000), .init(x: 0.600, y: 1.000),
                .init(x: 1.000, y: 1.000),
            ]
        }
    }

    /// An array of colors associated with the control points.
    public var colors: [Color] {
        switch self {
        case .intelligence:
            return [
                Color(hex: "#1BB1F9"), Color(hex: "#648EF2"),
                Color(hex: "#AE6FEE"),
                Color(hex: "#9B79F1"), Color(hex: "#ED50EB"),
                Color(hex: "#F65490"),
                Color(hex: "#F74A6B"), Color(hex: "#F47F3E"),
                Color(hex: "#ED8D02"),
            ]
        case .auroraBorealis:
            return [
                Color(hex: "#0073e6"), Color(hex: "#4da6ff"),
                Color(hex: "#b3d9ff"),
                Color(hex: "#00ff80"), Color(hex: "#66ffb3"),
                Color(hex: "#99ffcc"),
                Color(hex: "#004d40"), Color(hex: "#008577"),
                Color(hex: "#00a693"),
            ]
        case .sunsetGlow:
            return [
                Color(hex: "#F29933"), Color(hex: "#E66666"),
                Color(hex: "#B3337F"),
                Color(hex: "#CC4D80"), Color(hex: "#99194D"),
                Color(hex: "#660D33"),
                Color(hex: "#4D0D26"), Color(hex: "#330D1A"),
                Color(hex: "#1A0D0D"),
            ]
        case .oceanDepths:
            return [
                Color(hex: "#1A4D80"), Color(hex: "#0D3366"),
                Color(hex: "#00264D"),
                Color(hex: "#264D8C"), Color(hex: "#1A4073"),
                Color(hex: "#0D3366"),
                Color(hex: "#336699"), Color(hex: "#264D8C"),
                Color(hex: "#1A4D80"),
            ]
        case .neonNight:
            return [
                Color(hex: "#FF0080"), Color(hex: "#00FF80"),
                Color(hex: "#0080FF"),
                Color(hex: "#FF8000"), Color(hex: "#8000FF"),
                Color(hex: "#00FFFF"),
                Color(hex: "#FF00FF"), Color(hex: "#FFFF00"),
                Color(hex: "#80FF80"),
            ]
        case .autumnLeaves:
            return [
                Color(hex: "#CC4D00"), Color(hex: "#E66619"),
                Color(hex: "#B33300"),
                Color(hex: "#993319"), Color(hex: "#801910"),
                Color(hex: "#661A00"),
                Color(hex: "#4D0D00"), Color(hex: "#33190D"),
                Color(hex: "#1A0D00"),
            ]
        case .cosmicAurora:
            return [
                Color(hex: "#008050"), Color(hex: "#199966"),
                Color(hex: "#33B380"),
                Color(hex: "#4DCC99"), Color(hex: "#66E6B3"),
                Color(hex: "#80FFCC"),
                Color(hex: "#1A334D"), Color(hex: "#335266"),
                Color(hex: "#4D7080"),
            ]
        case .lavaFlow:
            return [
                Color(hex: "#FF0000"), Color(hex: "#E61A00"),
                Color(hex: "#CC3300"),
                Color(hex: "#B34D00"), Color(hex: "#996600"),
                Color(hex: "#808000"),
                Color(hex: "#660000"), Color(hex: "#4D0000"),
                Color(hex: "#330000"),
            ]
        case .etherealMist:
            return [
                Color(hex: "#F0F8FF"), Color(hex: "#E6F0FF"),
                Color(hex: "#D9E6FF"),
                Color(hex: "#CCE0FF"), Color(hex: "#B3D1FF"),
                Color(hex: "#99C2FF"),
                Color(hex: "#80B3FF"), Color(hex: "#66A3FF"),
                Color(hex: "#4D94FF"),
            ]
        case .tropicalParadise:
            return [
                Color(hex: "#00FF99"), Color(hex: "#33CC99"),
                Color(hex: "#66CC66"),
                Color(hex: "#99CC33"), Color(hex: "#CCCC00"),
                Color(hex: "#FFCC00"),
                Color(hex: "#FF9900"), Color(hex: "#FF6600"),
                Color(hex: "#FF3300"),
            ]
        case .midnightGalaxy:
            return [
                Color(hex: "#000066"), Color(hex: "#330066"),
                Color(hex: "#660066"),
                Color(hex: "#990066"), Color(hex: "#CC0066"),
                Color(hex: "#FF0066"),
                Color(hex: "#FF3399"), Color(hex: "#FF66CC"),
                Color(hex: "#FF99CC"),
            ]
        case .desertMirage:
            return [
                Color(hex: "#FFD699"), Color(hex: "#FFCC66"),
                Color(hex: "#FFC14D"),
                Color(hex: "#FFB833"), Color(hex: "#FFAD1A"),
                Color(hex: "#FFA500"),
                Color(hex: "#E69900"), Color(hex: "#CC8800"),
                Color(hex: "#B37700"),
            ]
        case .frostedCrystal:
            return [
                Color(hex: "#F0FAFF"), Color(hex: "#D6EBFF"),
                Color(hex: "#B8DCFF"),
                Color(hex: "#9ACDFF"), Color(hex: "#7CBEFF"),
                Color(hex: "#5EAFFF"),
                Color(hex: "#40A0FF"), Color(hex: "#2291FF"),
                Color(hex: "#0482FF"),
            ]
        case .enchantedForest:
            return [
                Color(hex: "#0A3A0A"), Color(hex: "#145214"),
                Color(hex: "#1E6A1E"),
                Color(hex: "#288228"), Color(hex: "#329B32"),
                Color(hex: "#3CB43C"),
                Color(hex: "#46CD46"), Color(hex: "#50E650"),
                Color(hex: "#5AFF5A"),
            ]
        case .rubyFusion:
            return [
                Color(hex: "#660000"), Color(hex: "#990000"),
                Color(hex: "#CC0000"),
                Color(hex: "#FF0000"), Color(hex: "#FF3333"),
                Color(hex: "#FF6666"),
                Color(hex: "#FF9999"), Color(hex: "#FFCCCC"),
                Color(hex: "#FFFFFF"),
            ]
        case .goldenSunrise:
            return [
                Color(hex: "#FFA500"), Color(hex: "#FFB52E"),
                Color(hex: "#FFC55C"),
                Color(hex: "#FFD58A"), Color(hex: "#FFE4B8"),
                Color(hex: "#FFF4E6"),
                Color(hex: "#FFFAF0"), Color(hex: "#FFFDF7"),
                Color(hex: "#FFFFFF"),
            ]
        case .cosmicNebula:
            return [
                Color(hex: "#000066"), Color(hex: "#3300CC"),
                Color(hex: "#6600FF"),
                Color(hex: "#9900FF"), Color(hex: "#CC00FF"),
                Color(hex: "#FF00FF"),
                Color(hex: "#FF33CC"), Color(hex: "#FF6699"),
                Color(hex: "#FF99CC"),
            ]
        case .arcticAurora:
            return [
                Color(hex: "#00264D"), Color(hex: "#004C99"),
                Color(hex: "#0072E6"),
                Color(hex: "#00A3FF"), Color(hex: "#33B8FF"),
                Color(hex: "#66CCFF"),
                Color(hex: "#99E0FF"), Color(hex: "#CCF2FF"),
                Color(hex: "#FFFFFF"),
            ]
        case .volcanicEmber:
            return [
                Color(hex: "#660000"), Color(hex: "#990000"),
                Color(hex: "#CC0000"),
                Color(hex: "#FF3300"), Color(hex: "#FF6600"),
                Color(hex: "#FF9900"),
                Color(hex: "#FFCC00"), Color(hex: "#FFFF00"),
                Color(hex: "#FFFFCC"),
            ]
        case .mintBreeze:
            return [
                Color(hex: "#CCFFE6"), Color(hex: "#99FFCC"),
                Color(hex: "#66FFB3"),
                Color(hex: "#33FF99"), Color(hex: "#00FF80"),
                Color(hex: "#00CC66"),
                Color(hex: "#009949"), Color(hex: "#006633"),
                Color(hex: "#00331A"),
            ]
        case .twilightSerenade:
            return [
                Color(hex: "#330066"), Color(hex: "#4D0099"),
                Color(hex: "#6600CC"),
                Color(hex: "#8000FF"), Color(hex: "#9933FF"),
                Color(hex: "#B266FF"),
                Color(hex: "#CC99FF"), Color(hex: "#E6CCFF"),
                Color(hex: "#FFFFFF"),
            ]
        case .saharaDunes:
            return [
                Color(hex: "#E6B366"), Color(hex: "#D9914D"),
                Color(hex: "#CC6E33"),
                Color(hex: "#BF4C1A"), Color(hex: "#B32900"),
                Color(hex: "#992200"),
                Color(hex: "#801A00"), Color(hex: "#661400"),
                Color(hex: "#4D0F00"),
            ]
        }
    }

    /// The background color of the gradient.
    public var background: Color {
        switch self {
        case .intelligence:
            return Color(hex: "#1BB1F9")
        case .auroraBorealis:
            return Color(hex: "#001a33")
        case .sunsetGlow:
            return Color(hex: "#1A0D26")
        case .oceanDepths:
            return Color(hex: "#0D1A33")
        case .neonNight:
            return Color(hex: "#0D001A")
        case .autumnLeaves:
            return Color(hex: "#33190D")
        case .cosmicAurora:
            return Color(hex: "#000919")
        case .lavaFlow:
            return Color(hex: "#330000")
        case .etherealMist:
            return Color(hex: "#E6F0FF")
        case .tropicalParadise:
            return Color(hex: "#006633")
        case .midnightGalaxy:
            return Color(hex: "#000033")
        case .desertMirage:
            return Color(hex: "#FFE6CC")
        case .frostedCrystal:
            return Color(hex: "#E0F0FF")
        case .enchantedForest:
            return Color(hex: "#0A2A0A")
        case .rubyFusion:
            return Color(hex: "#330000")
        case .goldenSunrise:
            return Color(hex: "#FFD700")
        case .cosmicNebula:
            return Color(hex: "#000033")
        case .arcticAurora:
            return Color(hex: "#001433")
        case .volcanicEmber:
            return Color(hex: "#330000")
        case .mintBreeze:
            return Color(hex: "#E0FFF0")
        case .twilightSerenade:
            return Color(hex: "#1A0033")
        case .saharaDunes:
            return Color(hex: "#F2D6A2")
        }
    }
}
