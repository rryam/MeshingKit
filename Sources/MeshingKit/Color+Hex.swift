//
//  Color+Hex.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/14/24.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct RGBAComponents {
    let r: Double
    let g: Double
    let b: Double
    let a: Double
}

extension Color {

    /// Initializes a `Color` instance from a hexadecimal color string.
    ///
    /// This initializer supports the following hex formats:
    /// - "#RGB" (12-bit)
    /// - "#RRGGBB" (24-bit)
    /// - "#AARRGGBB" (32-bit with alpha)
    ///
    /// - Parameter hex: A string representing the color in hexadecimal format.
    ///                  The "#" prefix is optional.
    ///
    /// - Note: If an invalid hex string is provided, the color will default to opaque white.
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        let scanned = Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch (scanned, hex.count) {
        case (true, 3):  // RGB (12-bit)
            (a, r, g, b) = (
                255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case (true, 6):  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case (true, 8):  // ARGB (32-bit)
            (a, r, g, b) = (
                int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF
            )
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func rgbaComponents() -> RGBAComponents? {
#if canImport(UIKit)
        let platformColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard platformColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        return RGBAComponents(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
#elseif canImport(AppKit)
        let platformColor = NSColor(self)
        let srgb = platformColor.usingColorSpace(.sRGB) ?? platformColor
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        return RGBAComponents(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
#else
        return nil
#endif
    }

    /// Returns a hex string for the color in sRGB space.
    ///
    /// - Parameter includeAlpha: When true, returns #AARRGGBB. Otherwise returns #RRGGBB.
    /// - Returns: A hex string if the color can be converted to sRGB.
    public func hexString(includeAlpha: Bool = false) -> String? {
        guard let components = rgbaComponents() else {
            return nil
        }

        let r = Int(round(components.r * 255))
        let g = Int(round(components.g * 255))
        let b = Int(round(components.b * 255))
        let a = Int(round(components.a * 255))

        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X", a, r, g, b)
        }
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
