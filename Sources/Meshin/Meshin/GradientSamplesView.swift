import SwiftUI
import MeshingKit
import Inject

/// A view that displays various gradient samples using MeshingKit.
///
/// This view showcases different gradient sizes and an animated gradient,
/// demonstrating the capabilities of the MeshingKit framework.
struct GradientSamplesView: View {
  @ObserveInjection var inject
  @State private var showAnimation = true

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        Text("MeshingKit Samples")
          .font(.largeTitle)
          .padding()

        GradientSize2View()

        GradientSize3View()

        GradientSize4View()

        AnimatedGradientView(showAnimation: $showAnimation)
      }
      .padding()
    }
    .enableInjection()
  }
}

/// A view that displays a size 2 gradient sample.
struct GradientSize2View: View {
  @ObserveInjection var inject

  var body: some View {
    VStack {
      Text("Gradient Size 2")
        .font(.headline)

      MeshingKit.gradientSize2(template: .mysticTwilight)
        .frame(width: 200, height: 200)
        .cornerRadius(20)
    }
    .enableInjection()
  }
}

/// A view that displays a size 3 gradient sample.
struct GradientSize3View: View {
  @ObserveInjection var inject

  var body: some View {
    VStack {
      Text("Gradient Size 3")
        .font(.headline)

      MeshingKit.gradientSize3(template: .cosmicAurora)
        .frame(width: 200, height: 200)
        .cornerRadius(20)
    }
    .enableInjection()
  }
}

/// A view that displays a size 4 gradient sample.
struct GradientSize4View: View {
  @ObserveInjection var inject

  var body: some View {
    VStack {
      Text("Gradient Size 4")
        .font(.headline)

      MeshingKit.gradientSize4(template: .auroraBorealis)
        .frame(width: 200, height: 200)
        .cornerRadius(20)
    }
    .enableInjection()
  }
}

/// A view that displays an animated gradient sample.
struct AnimatedGradientView: View {
  @ObserveInjection var inject
  @Binding var showAnimation: Bool

  var body: some View {
    VStack {
      Text("Animated Gradient")
        .font(.headline)

      MeshingKit.animatedGradientSize3(template: .intelligence, showAnimation: $showAnimation)
        .frame(width: 200, height: 200)
        .cornerRadius(20)

      Toggle("Show Animation", isOn: $showAnimation)
        .padding()
    }
    .enableInjection()
  }
}

struct GradientSamplesView_Previews: PreviewProvider {
  static var previews: some View {
    GradientSamplesView()
  }
}
