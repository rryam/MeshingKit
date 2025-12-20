# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MeshingKit is a Swift library for creating mesh gradients in SwiftUI. It provides 68 predefined gradient templates (2x2, 3x3, 4x4 grids), animated gradients, and Metal shader-based noise effects.

## Build Commands

```bash
# Swift Package Manager build
swift build

# Build for a specific target
swift build --target MeshingKit

# Xcode build for iOS Simulator
xcodebuild build -project Sources/Meshin/Meshin.xcodeproj -scheme Meshin -destination "generic/platform=iOS Simulator"
```

## Test Commands

```bash
swift test --verbose
swift test --enable-code-coverage
```

## Lint

```bash
swiftlint --strict
```

A pre-commit hook runs SwiftLint on staged files. Setup with `scripts/setup-hooks.sh`.

## Architecture

**Main API:** `MeshingKit.swift` exposes static `gradient()` and `animatedGradient()` methods.

**Template System:**
- `GradientTemplate` protocol defines the mesh gradient structure
- `PredefinedTemplate` enum wraps all 68 templates with metadata and search support
- Templates are organized by grid size: `GradientTemplateSize2`, `GradientTemplateSize3`, `GradientTemplateSize4`

**Key Views:**
- `AnimatedMeshGradientView` - SwiftUI view for animated gradients
- `ParameterizedNoiseView` - Metal shader noise effect

**Search:** `PredefinedTemplate.find(by: token)` uses NaturalLanguage for lemmatization and camelCase splitting.

## Important Conventions

- All public types conform to `Sendable` for concurrency safety
- Tests use Swift Testing framework with `#expect` macro
- Template files are excluded from SwiftLint (`.swiftlint.yml`) due to size
- CI runs on Codemagic (see `codemagic.yaml`)

## Source Structure

```
Sources/MeshingKit/     # Main library
Sources/Meshin/         # Demo app
Tests/MeshingKitTests/  # Swift Testing suite
scripts/                # Git hooks and setup
```
