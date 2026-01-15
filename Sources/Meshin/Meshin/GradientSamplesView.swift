//
//  GradientSamplesView.swift
//  Meshin
//
//  A view that displays a list of gradient templates with export functionality.
//

import SwiftUI
import MeshingKit
import Inject

/// Main view showing gradient templates with export options.
struct GradientSamplesView: View {
    @StateObject private var viewModel = MeshinViewModel()
    @ObserveInjection var inject

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Size 2 Templates")) {
                    ForEach(GradientTemplateSize2.allCases, id: \.self) { template in
                        TemplateRowView(
                            template: .size2(template),
                            viewModel: viewModel
                        )
                    }
                }

                Section(header: Text("Size 3 Templates")) {
                    ForEach(GradientTemplateSize3.allCases, id: \.self) { template in
                        TemplateRowView(
                            template: .size3(template),
                            viewModel: viewModel
                        )
                    }
                }

                Section(header: Text("Size 4 Templates")) {
                    ForEach(GradientTemplateSize4.allCases, id: \.self) { template in
                        TemplateRowView(
                            template: .size4(template),
                            viewModel: viewModel
                        )
                    }
                }
            }
            .navigationTitle("Gradient Templates")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    exportButton
                }
            }
            .sheet(item: $viewModel.selectedTemplate) { template in
                FullScreenGradientView(
                    template: template,
                    viewModel: viewModel
                )
            }
            .sheet(isPresented: $viewModel.showExportSheet) {
                ExportSheetView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.exportError != nil },
                set: { if !$0 { viewModel.clearMessages() } }
            )) {
                Button("OK") { viewModel.clearMessages() }
            } message: {
                Text(viewModel.exportError ?? "")
            }
            .alert("Success", isPresented: .init(
                get: { viewModel.exportSuccessMessage != nil },
                set: { if !$0 { viewModel.clearMessages() } }
            )) {
                Button("OK") { viewModel.clearMessages() }
            } message: {
                Text(viewModel.exportSuccessMessage ?? "")
            }
            .enableInjection()
        }
    }

    private var exportButton: some View {
        Button {
            viewModel.showExportOptions()
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }
}

/// A row view for displaying a template in the list.
struct TemplateRowView: View {
    let template: PredefinedTemplate
    let viewModel: MeshinViewModel

    var body: some View {
        Button {
            viewModel.selectedTemplate = template
        } label: {
            HStack {
                Text(template.name)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .imageScale(.small)
            }
        }
    }
}

/// Full-screen gradient view with export toolbar.
struct FullScreenGradientView: View {
    let template: PredefinedTemplate
    @ObservedObject var viewModel: MeshinViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAnimation: Bool = true

    var body: some View {
        ZStack {
            MeshingKit.animatedGradient(template, showAnimation: $showAnimation)

            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Toggle("Animate", isOn: $showAnimation)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: .rect)

                    HStack(spacing: 16) {
                        #if os(iOS)
                        Button {
                            viewModel.saveToPhotoLibrary()
                        } label: {
                            Label("Save Image", systemImage: "photo")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            viewModel.exportVideoToPhotoLibrary()
                        } label: {
                            Label("Export Video", systemImage: "video")
                        }
                        .buttonStyle(.borderedProminent)
                        #endif

                        #if os(macOS)
                        Button {
                            viewModel.saveToDisk(format: .png)
                        } label: {
                            Label("Save PNG", systemImage: "photo")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            viewModel.exportVideoToDisk()
                        } label: {
                            Label("Export Video", systemImage: "video")
                        }
                        .buttonStyle(.borderedProminent)
                        #endif
                    }
                    .disabled(viewModel.isExporting)

                    if viewModel.isExporting {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(8)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: .rect)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.bottom, 40)

                HStack {
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Text(template.name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea(edges: .all)
    }
}

/// Sheet view for selecting export options.
struct ExportSheetView: View {
    @ObservedObject var viewModel: MeshinViewModel
    @Environment(\.dismiss) private var dismiss

    private var hasSelection: Bool {
        viewModel.selectedTemplate != nil
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Image Export") {
                    #if os(iOS)
                    Button {
                        viewModel.saveToPhotoLibrary()
                        dismiss()
                    } label: {
                        Label("Save to Photo Library", systemImage: "photo.on.rectangle")
                    }
                    .disabled(!hasSelection)
                    #endif

                    #if os(macOS)
                    ForEach(viewModel.availableExportFormats) { format in
                        Button {
                            viewModel.saveToDisk(format: format)
                            dismiss()
                        } label: {
                            Label(
                                format.rawValue.uppercased(),
                                systemImage: "photo"
                            )
                        }
                        .disabled(!hasSelection)
                    }
                    #endif
                }

                Section("Video Export") {
                    #if os(iOS)
                    Button {
                        viewModel.exportVideoToPhotoLibrary()
                        dismiss()
                    } label: {
                        Label("Export Video to Photo Library", systemImage: "video")
                    }
                    .disabled(!hasSelection)
                    #endif

                    #if os(macOS)
                    Button {
                        viewModel.exportVideoToDisk()
                        dismiss()
                    } label: {
                        Label("Export Video to Disk", systemImage: "video")
                    }
                    .disabled(!hasSelection)
                    #endif
                }
            }
            .navigationTitle("Export Options")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.dismissExportSheet()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct GradientSamplesView_Previews: PreviewProvider {
    static var previews: some View {
        GradientSamplesView()
    }
}
