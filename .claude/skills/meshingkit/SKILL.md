---
name: meshingkit
description: Mesh gradient library for SwiftUI. Use for creating, animating, and exporting mesh gradients. Supports 2x2, 3x3, and 4x4 grid templates, animated gradients, Metal shaders, and platform-specific export to photo library or disk.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# MeshingKit

MeshingKit is a Swift package for creating mesh gradients in SwiftUI. It provides 68 predefined gradient templates, animated gradients, Metal shader noise effects, and platform-specific export functionality.

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
# Run tests with verbose output
swift test --verbose

# Run tests with code coverage
swift test --enable-code-coverage
```

## Lint

```bash
# Run SwiftLint with strict mode
swiftlint --strict

# Pre-commit hook runs on staged files
# Setup: scripts/setup-hooks.sh
```

## Architecture

### Main API

`MeshingKit.swift` exposes static methods for creating gradients:

```swift
// Create a static mesh gradient
MeshingKit.gradient(template: myTemplate)

// Create an animated mesh gradient view
MeshingKit.animatedGradient(template: myTemplate)

// Create with custom animation pattern
MeshingKit.animatedGradient(template: template, animationPattern: .fluid)
```

### Template System

**GradientTemplate Protocol:**

```swift
public protocol GradientTemplate: Sendable {
    var size: Int { get }
    var points: [SIMD2<Float>] { get }
    var colors: [Color] { get }
    var background: Color { get }
}
```

**Custom Template Example:**

```swift
struct MyGradient: GradientTemplate {
    var size: Int { 4 }

    var points: [SIMD2<Float>] {
        [
            SIMD2(0, 0), SIMD2(0.5, 0), SIMD2(1, 0),
            SIMD2(0, 0.5), SIMD2(0.5, 0.5), SIMD2(1, 0.5),
            SIMD2(0, 1), SIMD2(0.5, 1), SIMD2(1, 1)
        ]
    }

    var colors: [Color] {
        [.red, .green, .blue, .yellow, .purple, .orange, .pink, .cyan, .mint]
    }

    var background: Color { .black }
}
```

**PredefinedTemplate Enum:**

```swift
// All 68 templates
let allTemplates = PredefinedTemplate.allCases

// Search by name (uses NaturalLanguage)
let sunsetTemplates = PredefinedTemplate.find(by: "sunset")

// Access base template
let base = PredefinedTemplate.aurora.baseTemplate
```

Templates are organized by grid size:
- `GradientTemplateSize2` - 2x2 grids (4 points)
- `GradientTemplateSize3` - 3x3 grids (9 points)
- `GradientTemplateSize4` - 4x4 grids (16 points)

### Key Views

**AnimatedMeshGradientView:** SwiftUI view for animated gradients with configurable speed.

**ParameterizedNoiseView:** Metal shader-based noise effect for textures and visual effects.

### Search

`PredefinedTemplate.find(by: token)` uses:
- NaturalLanguage framework for lemmatization
- CamelCase splitting for method-style queries
- Semantic matching for gradient names

## Export APIs

### ExportFormat Enum

```swift
public enum ExportFormat: String, CaseIterable, Identifiable, Sendable {
    case png, jpg, mp4
    public var id: Self { self }
    public var fileExtension: String { rawValue }
}
```

### VideoExportError Enum

```swift
public enum VideoExportError: Error, Sendable {
    case frameRenderingFailed
    case failedToStartWriting
    case pixelBufferPoolCreationFailed
    case pixelBufferCreationFailed
    case failedToAppendPixelBuffer
    case failedToAddInput
    case failedToCreateOutputURL
    case fileNotAccessible
    case unsupportedFormat
    case photosPermissionDenied
}
```

### iOS - Photo Library

**saveGradientToPhotoAlbum:**

```swift
@MainActor
static func saveGradientToPhotoAlbum(
    template: any GradientTemplate,
    size: CGSize,
    scale: CGFloat = 1.0,
    blurRadius: CGFloat = 0,
    showDots: Bool = false,
    smoothsColors: Bool = true,
    completion: @escaping (Result<Void, Error>) -> Void
)
```

**exportVideoToPhotoLibrary:**

```swift
static func exportVideoToPhotoLibrary(
    template: any GradientTemplate,
    size: CGSize,
    duration: TimeInterval = 5.0,
    frameRate: Int32 = 30,
    blurRadius: CGFloat = 0,
    showDots: Bool = false,
    animate: Bool = true,
    smoothsColors: Bool = true,
    completion: @escaping (Result<URL, Error>) -> Void
)
```

**PhotoLibraryError:**

```swift
public enum PhotoLibraryError: Error, Sendable {
    case permissionDenied
    case saveFailed(Error)
}
```

### macOS - Disk Save

**saveToDisk:**

```swift
@MainActor
static func saveToDisk(
    image: NSImage,
    fileName: String = "gradient",
    format: ExportFormat = .png,
    completion: @escaping (Result<URL, Error>) -> Void
)
```

**saveGradientToDisk:**

```swift
@MainActor
static func saveGradientToDisk(
    template: any GradientTemplate,
    size: CGSize,
    scale: CGFloat = 1.0,
    blurRadius: CGFloat = 0,
    showDots: Bool = false,
    smoothsColors: Bool = true,
    fileName: String = "gradient",
    format: ExportFormat = .png,
    completion: @escaping (Result<URL, Error>) -> Void
)
```

**exportVideo (macOS):**

```swift
@MainActor
static func exportVideo(
    template: any GradientTemplate,
    size: CGSize,
    duration: TimeInterval = 5.0,
    frameRate: Int32 = 30,
    blurRadius: CGFloat = 0,
    showDots: Bool = false,
    animate: Bool = true,
    smoothsColors: Bool = true
) async throws -> URL
```

**SaveToDiskError:**

```swift
public enum SaveToDiskError: Error, Sendable {
    case userCancelled
    case cgImageCreationFailed
    case imageEncodingFailed(Error)
}
```

### Export Examples

**iOS - Save to Photo Library:**

```swift
MeshingKit.saveGradientToPhotoAlbum(
    template: .aurora,
    size: CGSize(width: 1080, height: 1920)
) { result in
    switch result {
    case .success:
        print("Saved to photo library!")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

**iOS - Export Video to Photo Library:**

```swift
MeshingKit.exportVideoToPhotoLibrary(
    template: .midnightDreams,
    size: CGSize(width: 1080, height: 1920),
    duration: 5.0,
    frameRate: 30
) { result in
    switch result {
    case .success(let url):
        print("Video saved: \(url)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

**macOS - Save to Disk:**

```swift
MeshingKit.saveGradientToDisk(
    template: .sunsetWave,
    size: CGSize(width: 1920, height: 1080),
    blurRadius: 10,
    fileName: "my-gradient",
    format: .png
) { result in
    switch result {
    case .success(let url):
        print("Saved to: \(url)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

**macOS - Export Video:**

```swift
let videoURL = try await MeshingKit.exportVideo(
    template: .aurora,
    size: CGSize(width: 1920, height: 1080),
    duration: 5.0,
    frameRate: 30,
    animate: true
)
print("Video exported to: \(videoURL)")
```

## Animation

### AnimatedMeshGradientView

```swift
struct AnimatedMeshGradientView: View {
    public let template: any GradientTemplate
    public let animationSpeed: Double

    public init(
        template: any GradientTemplate,
        animationSpeed: Double = 1.0
    )
}
```

### AnimationPattern

```swift
public enum AnimationPattern: String, CaseIterable, Identifiable, Sendable {
    case fluid, waves, ripples, pulse, none
}
```

### Animated Positions

The `GradientAnimation.swift` module provides animation functions for video export:

```swift
static func animatedPositions(
    for date: Double,
    positions: [SIMD2<Float>],
    animate: Bool
) -> [SIMD2<Float>]
```

## Metal Shaders

**ParameterizedNoiseView:**

Uses Metal shaders to generate procedural noise textures:

```swift
struct ParameterizedNoiseView: View {
    @State private var noiseParameter: Float = 0.5

    public init(parameter: Float = 0.5)

    public var body: some View { ... }
}
```

## Source Structure

```
Sources/MeshingKit/
├── MeshingKit.swift                       # Main API
├── GradientTemplate.swift                 # Protocol
├── PredefinedTemplate.swift               # 68 templates + search
├── GradientExport.swift                   # ExportFormat, VideoExportError
├── GradientExport+iOS.swift               # iOS photo library
├── GradientExport+macOS.swift             # macOS disk save
├── GradientAnimation.swift                # Animation functions
├── Color+Hex.swift                        # Color utilities
├── AnimatedMeshGradientView.swift         # Animated view
├── AnimationPattern.swift                 # Animation patterns
├── ParameterizedNoiseView.swift           # Metal shader noise
├── GradientTemplateSize2.swift            # 2x2 templates
├── GradientTemplateSize3.swift            # 3x3 templates
└── GradientTemplateSize4.swift            # 4x4 templates

Sources/Meshin/                            # Demo app
Tests/MeshingKitTests/                     # Swift Testing suite
scripts/                                   # Git hooks
codemagic.yaml                             # CI configuration
.swiftlint.yml                             # SwiftLint config
```

## Important Conventions

- All public types conform to `Sendable` for concurrency safety
- Tests use Swift Testing framework with `#expect` macro
- Template files are excluded from SwiftLint (see `.swiftlint.yml`) due to size
- CI runs on Codemagic (see `codemagic.yaml`)
- Video export uses streaming approach (memory-efficient)
- PredefinedTemplate uses NaturalLanguage for smart search

## Common Patterns

### Creating a Gradient View

```swift
let template = PredefinedTemplate.aurora
let gradientView = MeshingKit.gradient(template: template)
```

### Creating an Animated Gradient

```swift
let animatedView = MeshingKit.animatedGradient(
    template: PredefinedTemplate.midnightDreams,
    animationSpeed: 1.5
)
```

### Custom Animation Pattern

```swift
MeshingKit.animatedGradient(
    template: template,
    animationPattern: .waves
)
```

### Export with Customization

```swift
// iOS with blur
MeshingKit.saveGradientToPhotoAlbum(
    template: template,
    size: CGSize(width: 1080, height: 1920),
    blurRadius: 15,
    smoothsColors: true
) { /* ... */ }

// macOS with corner radius
MeshingKit.saveGradientToDisk(
    template: template,
    size: size,
    showDots: false
) { /* ... */ }
```

## Notes

- Grid sizes: 2x2 (4 points), 3x3 (9 points), 4x4 (16 points)
- Video export supports MP4 (H.264 codec)
- Image export supports PNG and JPG
- All async APIs properly handle MainActor isolation
- Error enums provide type-safe error handling
