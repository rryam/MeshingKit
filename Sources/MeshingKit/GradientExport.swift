//
//  GradientExport.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 12/19/25.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

public extension MeshingKit {
    /// Generates evenly spaced gradient stops for previewing template colors.
    static func previewStops(template: any GradientTemplate) -> [Gradient.Stop] {
        let colors = template.colors
        guard !colors.isEmpty else { return [] }

        let count = colors.count
        return colors.enumerated().map { index, color in
            let location = count == 1 ? 0.0 : Double(index) / Double(count - 1)
            return Gradient.Stop(color: color, location: location)
        }
    }

    /// Generates evenly spaced gradient stops for previewing predefined template colors.
    static func previewStops(template: PredefinedTemplate) -> [Gradient.Stop] {
        previewStops(template: template.baseTemplate)
    }

    /// Builds a SwiftUI snippet containing `Gradient.Stop` entries for a template.
    static func swiftUIStopsSnippet(
        template: any GradientTemplate,
        includeAlpha: Bool = false,
        precision: Int = 2
    ) -> String {
        let stops = previewStops(template: template)
        let format = "%.\(precision)f"
        let entries = stops.map { stop in
            let hex = stop.color.hexString(includeAlpha: includeAlpha) ?? "#FFFFFF"
            let location = String(format: format, stop.location)
            return ".init(color: Color(hex: \"\(hex)\"), location: \(location))"
        }

        return "[\(entries.joined(separator: ", "))]"
    }

    /// Builds a SwiftUI snippet containing `Gradient.Stop` entries for a predefined template.
    static func swiftUIStopsSnippet(
        template: PredefinedTemplate,
        includeAlpha: Bool = false,
        precision: Int = 2
    ) -> String {
        swiftUIStopsSnippet(template: template.baseTemplate, includeAlpha: includeAlpha, precision: precision)
    }

    /// Builds a CSS `linear-gradient` preview string for a template.
    static func cssLinearGradientSnippet(
        template: any GradientTemplate,
        angle: Double = 90,
        includeAlpha: Bool = false
    ) -> String {
        let stops = previewStops(template: template)
        let stopDescriptions = stops.map { stop in
            let percent = Int(round(stop.location * 100))
            let color = cssColorString(for: stop.color, includeAlpha: includeAlpha)
            return "\(color) \(percent)%"
        }

        let angleString = String(format: "%.0f", angle)
        return "linear-gradient(\(angleString)deg, \(stopDescriptions.joined(separator: ", ")))"
    }

    /// Builds a CSS `linear-gradient` preview string for a predefined template.
    static func cssLinearGradientSnippet(
        template: PredefinedTemplate,
        angle: Double = 90,
        includeAlpha: Bool = false
    ) -> String {
        cssLinearGradientSnippet(template: template.baseTemplate, angle: angle, includeAlpha: includeAlpha)
    }

    /// Renders a mesh gradient template to a CGImage snapshot.
    @MainActor
    static func snapshotCGImage(
        template: any GradientTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        smoothsColors: Bool = true
    ) -> CGImage? {
        let gradient = MeshingKit.gradient(template: template, smoothsColors: smoothsColors)
            .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: gradient)
        renderer.scale = scale
        renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)

        return renderer.cgImage
    }

    /// Renders a predefined template to a CGImage snapshot.
    @MainActor
    static func snapshotCGImage(
        template: PredefinedTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        smoothsColors: Bool = true
    ) -> CGImage? {
        snapshotCGImage(
            template: template.baseTemplate,
            size: size,
            scale: scale,
            smoothsColors: smoothsColors
        )
    }

#if canImport(UIKit)
    /// Renders a mesh gradient template to a UIImage snapshot.
    @MainActor
    static func snapshotImage(
        template: any GradientTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        smoothsColors: Bool = true
    ) -> UIImage? {
        guard let cgImage = snapshotCGImage(
            template: template,
            size: size,
            scale: scale,
            smoothsColors: smoothsColors
        ) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    /// Renders a predefined template to a UIImage snapshot.
    @MainActor
    static func snapshotImage(
        template: PredefinedTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        smoothsColors: Bool = true
    ) -> UIImage? {
        snapshotImage(
            template: template.baseTemplate,
            size: size,
            scale: scale,
            smoothsColors: smoothsColors
        )
    }
#elseif canImport(AppKit)
    /// Renders a mesh gradient template to an NSImage snapshot.
    @MainActor
    static func snapshotImage(
        template: any GradientTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        smoothsColors: Bool = true
    ) -> NSImage? {
        guard let cgImage = snapshotCGImage(
            template: template,
            size: size,
            scale: scale,
            smoothsColors: smoothsColors
        ) else {
            return nil
        }
        return NSImage(cgImage: cgImage, size: size)
    }

    /// Renders a predefined template to an NSImage snapshot.
    @MainActor
    static func snapshotImage(
        template: PredefinedTemplate,
        size: CGSize,
        scale: CGFloat = 1.0,
        smoothsColors: Bool = true
    ) -> NSImage? {
        snapshotImage(
            template: template.baseTemplate,
            size: size,
            scale: scale,
            smoothsColors: smoothsColors
        )
    }
#endif
}

private extension MeshingKit {
    static func cssColorString(for color: Color, includeAlpha: Bool) -> String {
        guard includeAlpha, let components = color.rgbaComponents() else {
            return color.hexString() ?? "#FFFFFF"
        }

        let r = Int(round(components.r * 255))
        let g = Int(round(components.g * 255))
        let b = Int(round(components.b * 255))
        let a = String(format: "%.2f", components.a)
        return "rgba(\(r), \(g), \(b), \(a))"
    }
}

private extension PredefinedTemplate {
    var baseTemplate: any GradientTemplate {
        switch self {
        case .size2(let specificTemplate): return specificTemplate
        case .size3(let specificTemplate): return specificTemplate
        case .size4(let specificTemplate): return specificTemplate
        }
    }
}
