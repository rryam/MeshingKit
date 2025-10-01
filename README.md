# MeshingKit

![Gradient](Sources/Resources/gradient.jpg)

![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)
![Build Status](https://github.com/rryam/MeshingKit/workflows/Build/badge.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)

MeshingKit provides an easy way to create mesh gradients in SwiftUI with predefined gradient templates to directly render beautiful, gorgeous gradients!

## Support

Love this project? Check out my books to explore more of AI and iOS development:
- [Exploring AI for iOS Development](https://academy.rudrank.com/product/ai)
- [Exploring AI-Assisted Coding for iOS Development](https://academy.rudrank.com/product/ai-assisted-coding)

Your support helps to keep this project growing!

## Meshing

MeshingKit is based on [Meshing](https://apps.apple.com/in/app/ai-mesh-gradient-tool-meshing/id6567933550), an AI Mesh Gradient Tool.

## Features

- Create beautiful mesh gradients with customizable control points and colors
- Animate gradients with smooth, configurable transitions
- 237 predefined gradient templates:
  - 44 templates with 2x2 grid size
  - 88 templates with 3x3 grid size
  - 105 templates with 4x4 grid size
- Easily extendable for custom gradients
- Works across all Apple platforms (iOS, macOS, tvOS, watchOS, visionOS)

## Requirements

- iOS 18.0+, macOS 15.0+, tvOS 18.0+, watchOS 11.0+, visionOS 2.0+
- Swift 6.2+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add MeshingKit to your project using Swift Package Manager. In Xcode, go to File > Swift Packages > Add Package Dependency and enter the following URL:

```
https://github.com/rryam/MeshingKit.git
```

## Usage

To use a predefined gradient template:

```swift
import SwiftUI
import MeshingKit

struct ContentView: View {
    var body: some View {
        // Using PredefinedTemplate enum (recommended)
        MeshingKit.gradient(template: .size3(.cosmicAurora))
            .frame(width: 300, height: 300)

        // Or using specific size methods
        MeshingKit.gradientSize3(template: .cosmicAurora)
            .frame(width: 300, height: 300)
    }
}
```

### Using PredefinedTemplate Enum

The `PredefinedTemplate` enum provides a unified way to access all gradient templates:

```swift
let gradient = MeshingKit.gradient(template: .size2(.mysticTwilight))
let gradient3 = MeshingKit.gradient(template: .size3(.auroraBorealis))
let gradient4 = MeshingKit.gradient(template: .size4(.cosmicNebula))
```

## Animated Gradient Views

To create an animated gradient view:

```swift
import SwiftUI
import MeshingKit

struct AnimatedGradientView: View {
    @State private var showAnimation = true

    var body: some View {
        MeshingKit.animatedGradient(
            .size3(.cosmicAurora),
            showAnimation: $showAnimation,
            animationSpeed: 1.5
        )
        .frame(width: 300, height: 300)
        .padding()

        // Toggle animation
        Toggle("Animate Gradient", isOn: $showAnimation)
            .padding()
    }
}
```

## Custom Animation Patterns

MeshingKit provides advanced animation control through `AnimationPattern` and `PointAnimation` structures:

```swift
import SwiftUI
import MeshingKit

struct CustomAnimationView: View {
    @State private var showAnimation = true

    var body: some View {
        // Use default animation pattern
        MeshingKit.animatedGradient(
            .size3(.cosmicAurora),
            showAnimation: $showAnimation,
            animationSpeed: 1.0
        )
        .frame(width: 300, height: 300)
    }
}
```

### Creating Custom Animation Patterns

You can create custom animations by defining specific point movements:

```swift
// Create custom point animations
let pointAnimations = [
    PointAnimation(pointIndex: 1, axis: .x, amplitude: 0.3, frequency: 1.2),
    PointAnimation(pointIndex: 4, axis: .both, amplitude: 0.2, frequency: 0.8),
    PointAnimation(pointIndex: 7, axis: .y, amplitude: -0.4, frequency: 1.5)
]

let customPattern = AnimationPattern(animations: pointAnimations)
```

**Animation Parameters:**
- `pointIndex`: Index of the point to animate in the gradient's position array
- `axis`: Which axis to animate (`.x`, `.y`, or `.both`)
- `amplitude`: How far the point moves from its original position
- `frequency`: Speed multiplier for the animation (default: 1.0)

## Noise Effect with Gradients

You can add a noise effect to your gradients using the ParameterizedNoiseView:

```swift
import SwiftUI
import MeshingKit

struct NoiseEffectGradientView: View {
    @State private var intensity: Float = 0.5
    @State private var frequency: Float = 0.2
    @State private var opacity: Float = 0.9

    var body: some View {
        ParameterizedNoiseView(intensity: $intensity, frequency: $frequency, opacity: $opacity) {
            MeshingKit.gradientSize3(template: .cosmicAurora)
        }
        .frame(width: 300, height: 300)

        // Controls for adjusting the noise effect
        VStack {
            Slider(value: $intensity, in: 0...1) {
                Text("Intensity")
            }
            .padding()

            Slider(value: $frequency, in: 0...1) {
                Text("Frequency")
            }
            .padding()

            Slider(value: $opacity, in: 0...1) {
                Text("Opacity")
            }
            .padding()
        }
    }
}
```

## Available Gradient Templates

MeshingKit provides 237 predefined gradient templates organized by grid size:

### Exploring Templates Programmatically

You can explore all available templates using the `CaseIterable` conformance:

```swift
// List all 3x3 templates
for template in GradientTemplateSize3.allCases {
    print(template.name)
}

// Get total count of templates for each size
let size2Count = GradientTemplateSize2.allCases.count // 44 templates
let size3Count = GradientTemplateSize3.allCases.count // 88 templates
let size4Count = GradientTemplateSize4.allCases.count // 105 templates
```

### Popular Template Examples

**2x2 Grid Templates (44 total):**
- mysticTwilight, tropicalParadise, cherryBlossom, arcticFrost
- goldenSunrise, emeraldForest, desertMirage, midnightGalaxy
- autumnHarvest, oceanBreeze, lavenderDreams, citrusBurst
- ...and 32 more templates

**3x3 Grid Templates (88 total):**
- intelligence, auroraBorealis, sunsetGlow, oceanDepths
- neonNight, autumnLeaves, cosmicAurora, lavaFlow
- etherealMist, tropicalParadise, midnightGalaxy, desertMirage
- ...and 76 more templates

**4x4 Grid Templates (105 total):**
- auroraBorealis, sunsetHorizon, mysticForest, cosmicNebula
- coralReef, etherealTwilight, volcanicOasis, arcticFrost
- jungleMist, desertMirage, neonMetropolis
- ...and 96 more templates

### Finding Templates by Name

Since templates follow `camelCase` naming, you can easily find them:

```swift
// Create a gradient from any template name
let template = GradientTemplateSize3.auroraBorealis
let gradient = MeshingKit.gradient(template: template)
```

## Custom Gradients

Create custom gradients by defining your own `GradientTemplate`:

```swift
let customTemplate = GradientTemplate(
    name: "Custom Gradient",
    size: 3,
    points: [
        .init(x: 0.0, y: 0.0), .init(x: 0.5, y: 0.0), .init(x: 1.0, y: 0.0),
        .init(x: 0.0, y: 0.5), .init(x: 0.5, y: 0.5), .init(x: 1.0, y: 0.5),
        .init(x: 0.0, y: 1.0), .init(x: 0.5, y: 1.0), .init(x: 1.0, y: 1.0)
    ],
    colors: [
        Color.red, Color.orange, Color.yellow,
        Color.green, Color.blue, Color.indigo,
        Color.purple, Color.pink, Color.white
    ],
    background: Color.black
)

let customGradient = MeshGradient(
    width: customTemplate.size,
    height: customTemplate.size,
    points: customTemplate.points,
    colors: customTemplate.colors
)
```

## Advanced Animation Examples

### Speed Control and Pausing

```swift
struct AdvancedAnimationView: View {
    @State private var showAnimation = true
    @State private var animationSpeed: Double = 1.0

    var body: some View {
        VStack {
            MeshingKit.animatedGradient(
                .size4(.cosmicNebula),
                showAnimation: $showAnimation,
                animationSpeed: animationSpeed
            )
            .frame(width: 400, height: 400)

            // Animation controls
            VStack {
                Toggle("Enable Animation", isOn: $showAnimation)

                Slider(value: $animationSpeed, in: 0.1...3.0) {
                    Text("Animation Speed: \(animationSpeed, specifier: "%.1f")x")
                }
            }
            .padding()
        }
    }
}
```

### Combining Animation with Noise Effects

```swift
struct AnimatedNoiseGradientView: View {
    @State private var showAnimation = true
    @State private var intensity: Float = 0.3
    @State private var frequency: Float = 0.2

    var body: some View {
        ParameterizedNoiseView(
            intensity: $intensity,
            frequency: $frequency,
            opacity: .constant(0.8)
        ) {
            MeshingKit.animatedGradient(
                .size3(.auroraBorealis),
                showAnimation: $showAnimation,
                animationSpeed: 1.2
            )
        }
        .frame(width: 300, height: 300)
    }
}
```

## Hex Color Initialization

There is an extension on `Color` that allows to initialise colors using hexadecimal strings:

```swift
let color = Color(hex: "#FF5733")
```

This extension supports various hex formats:

- "#RGB" (12-bit)
- "#RRGGBB" (24-bit)
- "#AARRGGBB" (32-bit with alpha)

## Contributing

Contributions to MeshingKit are welcome! Please feel free to submit a Pull Request.

## License

MeshingKit is available under the MIT license. See the LICENSE file for more info.
