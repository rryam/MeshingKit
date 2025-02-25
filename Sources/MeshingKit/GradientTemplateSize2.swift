//
//  GradientTemplateSize2.swift
//  MeshingKit
//
//  Created by Assistant on 10/14/24.
//

import SwiftUI

/// An enumeration of predefined gradient templates with a 2x2 grid size.
public enum GradientTemplateSize2: String, CaseIterable {
    case mysticTwilight
    case tropicalParadise
    case cherryBlossom
    case arcticFrost
    case goldenSunrise
    case emeraldForest
    case desertMirage
    case midnightGalaxy
    case autumnHarvest
    case oceanBreeze
    case lavenderDreams
    case citrusBurst
    case northernLights
    case strawberryLemonade
    case deepSea
    case cottonCandy
    case volcanicAsh
    case springMeadow
    case cosmicDust
    case peacockFeathers
    case crimsonSunset
    case enchantedForest
    case blueberryMuffin
    case saharaDunes
    case grapeSoda
    case frostyWinter
    case dragonFire
    case mermaidLagoon
    case chocolateTruffle
    case neonNights
    case fieryEmbers
    case morningDew
    case starryNight
    case auroraBorealis
    case sunsetBlaze

    /// The name of the gradient template.
    public var name: String {
        rawValue.capitalized
    }

    /// The size of the gradient, representing both width and height in pixels.
    public var size: Int {
        2
    }

    /// An array of 2D points that define the control points of the gradient.
    public var points: [SIMD2<Float>] {
        [
            .init(x: 0.000, y: 0.000),
            .init(x: 1.000, y: 0.000),
            .init(x: 0.000, y: 1.000),
            .init(x: 1.000, y: 1.000),
        ]
    }

    /// An array of colors associated with the control points.
    public var colors: [Color] {
        switch self {
        case .mysticTwilight:
            return [
                Color(hex: "#4B0082"), Color(hex: "#8A2BE2"),
                Color(hex: "#9400D3"), Color(hex: "#4169E1"),
            ]
        case .tropicalParadise:
            return [
                Color(hex: "#00FA9A"), Color(hex: "#1E90FF"),
                Color(hex: "#FFD700"), Color(hex: "#FF6347"),
            ]
        case .cherryBlossom:
            return [
                Color(hex: "#FFB7C5"), Color(hex: "#FF69B4"),
                Color(hex: "#FFC0CB"), Color(hex: "#DB7093"),
            ]
        case .arcticFrost:
            return [
                Color(hex: "#E0FFFF"), Color(hex: "#B0E0E6"),
                Color(hex: "#87CEEB"), Color(hex: "#4682B4"),
            ]
        case .goldenSunrise:
            return [
                Color(hex: "#FFA500"), Color(hex: "#FF8C00"),
                Color(hex: "#FF4500"), Color(hex: "#FF6347"),
            ]
        case .emeraldForest:
            return [
                Color(hex: "#00FF00"), Color(hex: "#32CD32"),
                Color(hex: "#008000"), Color(hex: "#006400"),
            ]
        case .desertMirage:
            return [
                Color(hex: "#DEB887"), Color(hex: "#D2691E"),
                Color(hex: "#CD853F"), Color(hex: "#8B4513"),
            ]
        case .midnightGalaxy:
            return [
                Color(hex: "#191970"), Color(hex: "#483D8B"),
                Color(hex: "#6A5ACD"), Color(hex: "#9370DB"),
            ]
        case .autumnHarvest:
            return [
                Color(hex: "#D2691E"), Color(hex: "#FF7F50"),
                Color(hex: "#CD5C5C"), Color(hex: "#8B0000"),
            ]
        case .oceanBreeze:
            return [
                Color(hex: "#00CED1"), Color(hex: "#20B2AA"),
                Color(hex: "#48D1CC"), Color(hex: "#40E0D0"),
            ]
        case .lavenderDreams:
            return [
                Color(hex: "#9370DB"), Color(hex: "#8A2BE2"),
                Color(hex: "#9932CC"), Color(hex: "#BA55D3"),
            ]
        case .citrusBurst:
            return [
                Color(hex: "#FFD700"), Color(hex: "#FFA500"),
                Color(hex: "#FF8C00"), Color(hex: "#FF7F50"),
            ]
        case .northernLights:
            return [
                Color(hex: "#00FF00"), Color(hex: "#00FFFF"),
                Color(hex: "#FF00FF"), Color(hex: "#4B0082"),
            ]
        case .strawberryLemonade:
            return [
                Color(hex: "#FFB6C1"), Color(hex: "#FFC0CB"),
                Color(hex: "#FAFAD2"), Color(hex: "#FFFFE0"),
            ]
        case .deepSea:
            return [
                Color(hex: "#191970"), Color(hex: "#00008B"),
                Color(hex: "#0000CD"), Color(hex: "#4169E1"),
            ]
        case .cottonCandy:
            return [
                Color(hex: "#FF69B4"), Color(hex: "#FFB6C1"),
                Color(hex: "#E6E6FA"), Color(hex: "#B0E0E6"),
            ]
        case .volcanicAsh:
            return [
                Color(hex: "#2F4F4F"), Color(hex: "#696969"),
                Color(hex: "#778899"), Color(hex: "#A9A9A9"),
            ]
        case .springMeadow:
            return [
                Color(hex: "#98FB98"), Color(hex: "#00FA9A"),
                Color(hex: "#7FFF00"), Color(hex: "#32CD32"),
            ]
        case .cosmicDust:
            return [
                Color(hex: "#4B0082"), Color(hex: "#8A2BE2"),
                Color(hex: "#9932CC"), Color(hex: "#E6E6FA"),
            ]
        case .peacockFeathers:
            return [
                Color(hex: "#1E90FF"), Color(hex: "#00CED1"),
                Color(hex: "#20B2AA"), Color(hex: "#008080"),
            ]
        case .crimsonSunset:
            return [
                Color(hex: "#FF4500"), Color(hex: "#FF6347"),
                Color(hex: "#FF7F50"), Color(hex: "#FFA07A"),
            ]
        case .enchantedForest:
            return [
                Color(hex: "#006400"), Color(hex: "#008000"),
                Color(hex: "#2E8B57"), Color(hex: "#3CB371"),
            ]
        case .blueberryMuffin:
            return [
                Color(hex: "#1E90FF"), Color(hex: "#6495ED"),
                Color(hex: "#87CEFA"), Color(hex: "#B0E0E6"),
            ]
        case .saharaDunes:
            return [
                Color(hex: "#D2691E"), Color(hex: "#CD853F"),
                Color(hex: "#DEB887"), Color(hex: "#FFDAB9"),
            ]
        case .grapeSoda:
            return [
                Color(hex: "#4B0082"), Color(hex: "#8A2BE2"),
                Color(hex: "#9932CC"), Color(hex: "#BA55D3"),
            ]
        case .frostyWinter:
            return [
                Color(hex: "#E0FFFF"), Color(hex: "#B0E0E6"),
                Color(hex: "#AFEEEE"), Color(hex: "#E6E6FA"),
            ]
        case .dragonFire:
            return [
                Color(hex: "#FF4500"), Color(hex: "#FF6347"),
                Color(hex: "#FF7F50"), Color(hex: "#FFA500"),
            ]
        case .mermaidLagoon:
            return [
                Color(hex: "#00CED1"), Color(hex: "#48D1CC"),
                Color(hex: "#40E0D0"), Color(hex: "#7FFFD4"),
            ]
        case .chocolateTruffle:
            return [
                Color(hex: "#8B4513"), Color(hex: "#A0522D"),
                Color(hex: "#CD853F"), Color(hex: "#D2691E"),
            ]
        case .neonNights:
            return [
                Color(hex: "#FF00FF"), Color(hex: "#00FFFF"),
                Color(hex: "#FF1493"), Color(hex: "#00FF00"),
            ]
        case .fieryEmbers:
            return [
                Color(hex: "#FF6347"), Color(hex: "#FF4500"),
                Color(hex: "#FF7F50"), Color(hex: "#FFA500"),
            ]
        case .morningDew:
            return [
                Color(hex: "#98FB98"), Color(hex: "#00FA9A"),
                Color(hex: "#7FFF00"), Color(hex: "#32CD32"),
            ]
        case .starryNight:
            return [
                Color(hex: "#191970"), Color(hex: "#483D8B"),
                Color(hex: "#6A5ACD"), Color(hex: "#9370DB"),
            ]
        case .auroraBorealis:
            return [
                Color(hex: "#00FF00"), Color(hex: "#00FFFF"),
                Color(hex: "#FF00FF"), Color(hex: "#4B0082"),
            ]
        case .sunsetBlaze:
            return [
                Color(hex: "#FF4500"), Color(hex: "#FF6347"),
                Color(hex: "#FF7F50"), Color(hex: "#FFA07A"),
            ]
        }
    }

    /// The background color of the gradient.
    public var background: Color {
        switch self {
        case .mysticTwilight:
            return Color(hex: "#1A0033")
        case .tropicalParadise:
            return Color(hex: "#006644")
        case .cherryBlossom:
            return Color(hex: "#FFF0F5")
        case .arcticFrost:
            return Color(hex: "#F0FFFF")
        case .goldenSunrise:
            return Color(hex: "#FFD700")
        case .emeraldForest:
            return Color(hex: "#004D40")
        case .desertMirage:
            return Color(hex: "#F4A460")
        case .midnightGalaxy:
            return Color(hex: "#000033")
        case .autumnHarvest:
            return Color(hex: "#8B4513")
        case .oceanBreeze:
            return Color(hex: "#E0FFFF")
        case .lavenderDreams:
            return Color(hex: "#E6E6FA")
        case .citrusBurst:
            return Color(hex: "#FFF700")
        case .northernLights:
            return Color(hex: "#000033")
        case .strawberryLemonade:
            return Color(hex: "#FFFACD")
        case .deepSea:
            return Color(hex: "#000080")
        case .cottonCandy:
            return Color(hex: "#FFBCD9")
        case .volcanicAsh:
            return Color(hex: "#1C1C1C")
        case .springMeadow:
            return Color(hex: "#90EE90")
        case .cosmicDust:
            return Color(hex: "#2D2D2D")
        case .peacockFeathers:
            return Color(hex: "#00A86B")
        case .crimsonSunset:
            return Color(hex: "#DC143C")
        case .enchantedForest:
            return Color(hex: "#228B22")
        case .blueberryMuffin:
            return Color(hex: "#4169E1")
        case .saharaDunes:
            return Color(hex: "#F4A460")
        case .grapeSoda:
            return Color(hex: "#8E4585")
        case .frostyWinter:
            return Color(hex: "#F0F8FF")
        case .dragonFire:
            return Color(hex: "#8B0000")
        case .mermaidLagoon:
            return Color(hex: "#20B2AA")
        case .chocolateTruffle:
            return Color(hex: "#3C2A21")
        case .neonNights:
            return Color(hex: "#000000")
        case .fieryEmbers:
            return Color(hex: "#FF6347")
        case .morningDew:
            return Color(hex: "#98FB98")
        case .starryNight:
            return Color(hex: "#191970")
        case .auroraBorealis:
            return Color(hex: "#000033")
        case .sunsetBlaze:
            return Color(hex: "#FF4500")
        }
    }
}
