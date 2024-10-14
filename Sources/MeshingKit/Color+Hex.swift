//
//  Color+Hex.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 10/14/24.
//

import SwiftUI

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
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}