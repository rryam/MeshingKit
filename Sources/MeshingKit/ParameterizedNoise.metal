//
//  Shader.metal
//  MeshingShared
//
//  Created by Rudrank Riyam on 8/9/24.
//

#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 parameterizedNoise(float2 position, half4 color, float intensity, float frequency, float opacity) {
  float value = fract(cos(dot(position * frequency, float2(12.9898, 78.233))) * 43758.5453);

  float r = color.r * mix(1.0, value, intensity);
  float g = color.g * mix(1.0, value, intensity);
  float b = color.b * mix(1.0, value, intensity);

  return half4(r, g, b, color.a * opacity);
}
