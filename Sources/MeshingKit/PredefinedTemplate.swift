//
//  PredefinedTemplate.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 2/25/25.
//

import Foundation
import SwiftUI
#if canImport(NaturalLanguage)
import NaturalLanguage
#endif

/// A type representing predefined gradient templates of different sizes.
public enum PredefinedTemplate: Identifiable, CaseIterable, Equatable, Sendable {
    case size2(GradientTemplateSize2)
    case size3(GradientTemplateSize3)
    case size4(GradientTemplateSize4)

    /// All predefined templates across all sizes.
    ///
    /// This property provides access to all templates in a single collection for easy iteration.
    public static var allCases: [PredefinedTemplate] {
        GradientTemplateSize2.allCases.map(PredefinedTemplate.size2)
            + GradientTemplateSize3.allCases.map(PredefinedTemplate.size3)
            + GradientTemplateSize4.allCases.map(PredefinedTemplate.size4)
    }

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

    /// Returns the underlying base template for this predefined template.
    var baseTemplate: any GradientTemplate {
        switch self {
        case .size2(let template): return template
        case .size3(let template): return template
        case .size4(let template): return template
        }
    }
}

/// Describes the mood of a gradient template for browsing and search.
public enum TemplateMood: String, CaseIterable, Sendable {
    case aquatic
    case bright
    case cool
    case cosmic
    case dark
    case earthy
    case fiery
    case vibrant
    case warm
}

/// Metadata for a predefined template.
public struct TemplateMetadata: Sendable {
    public let name: String
    public let tags: [String]
    public let moods: [TemplateMood]
    public let palette: [Color]
    public let background: Color

    public init(
        name: String,
        tags: [String],
        moods: [TemplateMood],
        palette: [Color],
        background: Color
    ) {
        self.name = name
        self.tags = tags
        self.moods = moods
        self.palette = palette
        self.background = background
    }
}

public extension PredefinedTemplate {
    /// Template metadata computed on demand.
    package var metadataValue: TemplateMetadata {
        Self.metadataByID[id] ?? Self.makeMetadata(for: self)
    }

    /// The underlying template for this predefined case.
    package var template: any GradientTemplate {
        switch self {
        case .size2(let specificTemplate): return specificTemplate
        case .size3(let specificTemplate): return specificTemplate
        case .size4(let specificTemplate): return specificTemplate
        }
    }

    /// A user-facing name for the template.
    var name: String {
        template.name
    }

    /// The palette colors for the template.
    var palette: [Color] {
        metadataValue.palette
    }

    /// The background color for the template.
    var background: Color {
        metadataValue.background
    }

    /// Tags derived from the template name and mood.
    var tags: [String] {
        metadataValue.tags
    }

    /// Moods derived from the template name.
    var moods: [TemplateMood] {
        metadataValue.moods
    }

    /// Combined metadata for the template.
    var metadata: TemplateMetadata {
        metadataValue
    }

    /// Finds templates that best match the query.
    ///
    /// - Parameters:
    ///   - query: Search terms (tags or mood keywords).
    ///   - limit: Optional limit for the number of results.
    /// - Returns: Templates ordered by best match.
    static func find(by query: String, limit: Int? = nil) -> [PredefinedTemplate] {
        let queryTokens = normalizedTokens(from: query)
        guard !queryTokens.isEmpty else {
            return allCases
        }

        let results = searchIndex.compactMap { entry -> (score: Int, template: PredefinedTemplate)? in
            let score = matchScore(for: queryTokens, in: entry.tokens)
            return score > 0 ? (score, entry.template) : nil
        }
        .sorted { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.template.id < rhs.template.id
            }
            return lhs.score > rhs.score
        }
        .map { $0.template }

        if let limit {
            guard limit >= 0 else { return [] }
            return Array(results.prefix(limit))
        }
        return results
    }
}

private extension PredefinedTemplate {
    struct SearchIndexEntry: Sendable {
        let template: PredefinedTemplate
        let tokens: [String]
    }

    var rawName: String {
        switch self {
        case .size2(let specificTemplate): return specificTemplate.rawValue
        case .size3(let specificTemplate): return specificTemplate.rawValue
        case .size4(let specificTemplate): return specificTemplate.rawValue
        }
    }

    static func makeMetadata(for template: PredefinedTemplate) -> TemplateMetadata {
        let nameTokens = normalizedTokens(from: template.rawName)
        let moodList = moods(for: nameTokens)
        let moodTokens = moodList.map(\.rawValue)
        let tags = uniqueTokens(nameTokens + moodTokens)

        return TemplateMetadata(
            name: template.template.name,
            tags: tags,
            moods: moodList,
            palette: template.template.colors,
            background: template.template.background
        )
    }

    static let indexedTemplates: [(template: PredefinedTemplate, metadata: TemplateMetadata)] = {
        allCases.map { template in
            (template: template, metadata: makeMetadata(for: template))
        }
    }()

    static let metadataByID: [String: TemplateMetadata] = {
        Dictionary(
            uniqueKeysWithValues: indexedTemplates.map { entry in
                (entry.template.id, entry.metadata)
            }
        )
    }()

    static let searchIndex: [SearchIndexEntry] = {
        indexedTemplates.map { entry in
            SearchIndexEntry(
                template: entry.template,
                tokens: entry.metadata.tags
            )
        }
    }()

    static func moods(for tokens: [String]) -> [TemplateMood] {
        var matched: [TemplateMood] = []

        for (mood, keywords) in moodKeywords where tokens.contains(where: keywords.contains) {
            matched.append(mood)
        }

        return matched
    }

    static func matchScore(for queryTokens: [String], in tokens: [String]) -> Int {
        var score = 0

        for query in queryTokens {
            if tokens.contains(query) {
                score += 3
                continue
            }

            if tokens.contains(where: { $0.hasPrefix(query) }) {
                score += 2
                continue
            }

            if tokens.contains(where: { $0.contains(query) }) {
                score += 1
            }
        }

        return score
    }

    static func normalizedTokens(from string: String) -> [String] {
        let rawTokens = basicTokens(from: string)
#if canImport(NaturalLanguage)
        return rawTokens.map { lemmatize($0) }
#else
        return rawTokens
#endif
    }

    static func basicTokens(from string: String) -> [String] {
        let components = string
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }

        let splitTokens = components.flatMap { splitCamelCase($0) }
        return splitTokens.map { $0.lowercased() }
    }

    static func splitCamelCase(_ string: String) -> [String] {
        var tokens: [String] = []
        var current = ""

        for character in string {
            if character.isUppercase, !current.isEmpty {
                tokens.append(current)
                current = ""
            }
            current.append(character)
        }

        if !current.isEmpty {
            tokens.append(current)
        }

        return tokens
    }

    static func uniqueTokens(_ tokens: [String]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []

        for token in tokens where seen.insert(token).inserted {
            result.append(token)
        }

        return result
    }

    static let moodKeywords: [TemplateMood: Set<String>] = [
        .aquatic: ["ocean", "sea", "lagoon", "breeze", "mist"],
        .bright: ["sunrise", "morning", "glow", "dawn"],
        .cool: ["arctic", "frost", "winter", "ice", "mint"],
        .cosmic: ["cosmic", "aurora", "nebula", "galaxy", "starry"],
        .dark: ["midnight", "night", "shadow"],
        .earthy: ["forest", "meadow", "jungle", "dunes", "desert"],
        .fiery: ["ember", "lava", "volcanic", "fire", "blaze"],
        .vibrant: ["neon", "electric", "citrus"],
        .warm: ["sunset", "golden", "autumn", "crimson"]
    ]

#if canImport(NaturalLanguage)
    static func lemmatize(_ token: String) -> String {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = token
        let (tag, _) = tagger.tag(at: token.startIndex, unit: .word, scheme: .lemma)
        if let lemma = tag?.rawValue, !lemma.isEmpty, lemma != token {
            return lemma
        }
        return token.lowercased()
    }
#endif
}
