---
name: meshingkit
description: Mesh gradient library for SwiftUI. Use for creating, animating, and exporting mesh gradients. Supports 2x2, 3x3, and 4x4 grid templates, Metal shaders, and platform-specific export to photo library or disk.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# MeshingKit

## What is MeshingKit?

MeshingKit is a Swift library for creating mesh gradients in SwiftUI. It provides:
- 68 predefined gradient templates (2x2, 3x3, 4x4 grids)
- Animated gradients with smooth motion patterns
- Metal shader-based noise effects
- Platform-specific export (images, PNGs, videos)

## Key APIs

### Creating Gradients

```swift
// Basic gradient from template
let gradient = MeshingKit.gradient(template: myTemplate)

// Animated gradient view
let animatedView = MeshingKit.animatedGradient(template: myTemplate)
```

### Predefined Templates

```swift
// Browse all templates
let allTemplates = PredefinedTemplate.allCases

// Search by name
let found = PredefinedTemplate.find(by: "sunset")

// Access base template
let base = PredefinedTemplate.sunset.baseTemplate
```

### Custom Templates

```swift
struct MyTemplate: GradientTemplate {
    var size: Int { 4 }
    var points: [SIMD2<Float>] { [...] }
    var colors: [Color] { [.red, .blue, .green, .yellow] }
    var background: Color { .black }
}
```

## Export APIs

### iOS - Photo Library

```swift
// Save gradient image to photo library
MeshingKit.saveGradientToPhotoAlbum(
    template: template,
    size: CGSize(width: 1080, height: 1920),
    scale: 2.0,
    blurRadius: 0,
    showDots: false,
    smoothsColors: true
) { result in
    switch result {
    case .success: print("Saved!")
    case .failure(let error): print("Error: \(error)")
    }
}

// Export video to photo library
MeshingKit.exportVideoToPhotoLibrary(
    template: template,
    size: CGSize(width: 1080, height: 1920),
    duration: 5.0,
    frameRate: 30
) { result in
    // Handle result
}
```

### macOS - Disk Save

```swift
// Save to disk with file dialog
MeshingKit.saveGradientToDisk(
    template: template,
    size: CGSize(width: 1920, height: 1080),
    fileName: "my-gradient",
    format: .png
) { result in
    switch result {
    case .success(let url): print("Saved to \(url)")
    case .failure(let error): print("Error: \(error)")
    }
}

// Export video to disk
let videoURL = try await MeshingKit.exportVideo(
    template: template,
    size: CGSize(width: 1920, height: 1080),
    duration: 5.0,
    frameRate: 30,
    blurRadius: 0,
    animate: true
)
```

## Error Types

### VideoExportError
- `.frameRenderingFailed`
- `.failedToStartWriting`
- `.pixelBufferCreationFailed`
- `.failedToAppendPixelBuffer`
- `.photosPermissionDenied`

### SaveToDiskError (macOS)
- `.userCancelled`
- `.cgImageCreationFailed`
- `.imageEncodingFailed(Error)`

### PhotoLibraryError (iOS)
- `.permissionDenied`
- `.saveFailed(Error)`

## File Structure

```
Sources/MeshingKit/
├── MeshingKit.swift              # Main API (gradient, animatedGradient)
├── GradientTemplate.swift        # Protocol definition
├── PredefinedTemplate.swift      # 68 templates + search
├── GradientExport.swift          # ExportFormat, VideoExportError
├── GradientExport+iOS.swift      # iOS photo library APIs
├── GradientExport+macOS.swift    # macOS disk save APIs
├── GradientAnimation.swift       # Animated positions
└── ...

Tests/MeshingKitTests/
├── MeshingKitTests.swift
├── PredefinedTemplateTests.swift
└── ExportTests.swift
```

## Build & Test

```bash
# Build
swift build

# Test
swift test --verbose

# Lint
swiftlint --strict
```

## Common Patterns

### Creating Animated Gradients

```swift
let template = PredefinedTemplate.aurora
let view = MeshingKit.animatedGradient(
    template: template,
    animationSpeed: 1.0
)
```

### Custom Animation Pattern

```swift
MeshingKit.animatedGradient(
    template: template,
    animationPattern: .fluid
)
```

### Export with Blur

```swift
MeshingKit.saveGradientToDisk(
    template: template,
    size: size,
    blurRadius: 20
) { /* ... */ }
```

## Supported Formats

- **Images**: PNG, JPG
- **Video**: MP4 (H.264)
- **Photo Library**: iOS only

## Notes

- All public types conform to `Sendable` for concurrency safety
- Video export uses streaming approach (memory-efficient)
- Templates are organized by grid size (2x2, 3x3, 4x4)
- PredefinedTemplate uses NaturalLanguage for smart search
