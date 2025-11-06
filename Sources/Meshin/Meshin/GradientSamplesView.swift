import SwiftUI
import MeshingKit
import Inject

/// A view that displays a list of gradient templates and allows full-screen viewing.
struct GradientSamplesView: View {
  @ObserveInjection var inject
  @State private var selectedTemplate: PredefinedTemplate?

  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("Size 2 Templates")) {
          ForEach(GradientTemplateSize2.allCases, id: \.self) { template in
            Button(template.name) {
              selectedTemplate = .size2(template)
            }
          }
        }

        Section(header: Text("Size 3 Templates")) {
          ForEach(GradientTemplateSize3.allCases, id: \.self) { template in
            Button(template.name) {
              selectedTemplate = .size3(template)
            }
          }
        }

        Section(header: Text("Size 4 Templates")) {
          ForEach(GradientTemplateSize4.allCases, id: \.self) { template in
            Button(template.name) {
              selectedTemplate = .size4(template)
            }
          }
        }
      }
      .navigationTitle("Gradient Templates")
    }
    .sheet(item: $selectedTemplate) { template in
      FullScreenGradientView(template: template)
    }
    .enableInjection()
  }
}

/// A view that displays a full-screen version of a selected gradient template.
struct FullScreenGradientView: View {
  let template: PredefinedTemplate
  @Environment(\.presentationMode) var presentationMode
  @State private var showAnimation: Bool = false

  var body: some View {
    ZStack {
      MeshingKit.animatedGradient(template, showAnimation: $showAnimation)

      VStack {
        Spacer()

        Toggle("Animate", isOn: $showAnimation)
          .padding()
          .background(.ultraThinMaterial, in: .rect)

        Button("Close") {
          presentationMode.wrappedValue.dismiss()
        }
        .padding(.bottom)
        .buttonStyle(.borderedProminent)
      }
    }
    .edgesIgnoringSafeArea(.all)
  }
}

struct GradientSamplesView_Previews: PreviewProvider {
  static var previews: some View {
    GradientSamplesView()
  }
}
