//
//  ImageFlattening.swift
//  MeshingKit
//

import SwiftUI

#if os(macOS)
import CoreGraphics

extension MeshingKit {
    /// Composites an image with alpha over an opaque white background.
    ///
    /// - Returns: The flattened image, or `nil` if a drawing context could not be made.
    static func flattenedOnWhite(_ image: CGImage) -> CGImage? {
        guard let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }

        let bounds = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        context.setFillColor(gray: 1, alpha: 1)
        context.fill(bounds)
        context.draw(image, in: bounds)
        return context.makeImage()
    }
}
#endif
