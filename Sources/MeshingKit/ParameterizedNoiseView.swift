import SwiftUI

/// A view that applies a parameterized noise effect to a MeshGradient.
///
/// Use `ParameterizedNoiseView` to add a customizable noise effect to a `MeshGradient` view.
/// The noise effect is controlled by three parameters: intensity, frequency, and opacity.
///
/// Example usage:
/// ```swift
/// ParameterizedNoiseView(intensity: .constant(0.5), frequency: .constant(0.2), opacity: .constant(0.9)) {
///   MeshingKit.gradientSize3(template: .cosmicAurora)
/// }
/// ```
///
/// - Important: This view requires iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, or visionOS 2.0 and later.
public struct ParameterizedNoiseView: View {
  
  /// The MeshGradient to which the noise effect is applied.
  let gradient: MeshGradient
  
  /// The intensity of the noise effect.
  ///
  /// Values typically range from 0 to 1, where 0 means no effect and 1 means maximum intensity.
  @Binding var intensity: Float
  
  /// The frequency of the noise pattern.
  ///
  /// Higher values create a finer, more detailed noise pattern, while lower values create a broader, more spread-out pattern.
  @Binding var frequency: Float
  
  /// The opacity of the noise effect.
  ///
  /// Values range from 0 to 1, where 0 is completely transparent and 1 is fully opaque.
  @Binding var opacity: Float

  /// Creates a new `ParameterizedNoiseView` with the specified parameters and MeshGradient.
  ///
  /// - Parameters:
  ///   - intensity: A binding to the intensity of the noise effect.
  ///   - frequency: A binding to the frequency of the noise pattern.
  ///   - opacity: A binding to the opacity of the noise effect.
  ///   - content: A closure that returns the MeshGradient to which the noise effect will be applied.
  public init(intensity: Binding<Float>, frequency: Binding<Float>, opacity: Binding<Float>, @ViewBuilder content: () -> MeshGradient) {
    self._intensity = intensity
    self._frequency = frequency
    self._opacity = opacity
    self.gradient = content()
  }

  /// The body of the view, applying the noise effect to the MeshGradient.
  public var body: some View {
    gradient
      .colorEffect(
        ShaderLibrary.parameterizedNoise(
          .float(intensity),
          .float(frequency),
          .float(opacity)
        )
      )
  }
}
