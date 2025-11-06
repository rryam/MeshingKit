//
//  PredefinedTemplate.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 2/25/25.
//

import Foundation

/// A type representing predefined gradient templates of different sizes.
public enum PredefinedTemplate: Identifiable {
    case size2(GradientTemplateSize2)
    case size3(GradientTemplateSize3)
    case size4(GradientTemplateSize4)

    /// A unique identifier for the template.
    ///
    /// The identifier is constructed from the template size and the template's raw value,
    /// ensuring uniqueness across all predefined templates.
    public var id: String {
        switch self {
        case .size2(let template): return "size2_\(template.rawValue)"
        case .size3(let template): return "size3_\(template.rawValue)"
        case .size4(let template): return "size4_\(template.rawValue)"
        }
    }
}
