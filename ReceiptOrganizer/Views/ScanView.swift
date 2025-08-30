import SwiftUI

struct ScanView: View {
    @EnvironmentObject private var store: ReceiptStore
    @State private var showCamera = false
    @State private var isProcessing = false
    @State private var lastLines: [String] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Scan a receipt using your camera. Lines will be extracted with on‑device OCR.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button(action: { showCamera = true }) {
                    Label("Scan Receipt", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)

                if isProcessing {
                    ProgressView("Recognizing text…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !lastLines.isEmpty {
                    List {
                        Section("Extracted Lines") {
                            ForEach(lastLines, id: \.self) { line in
                                Text(line)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("No scan yet", systemImage: "doc.text.viewfinder", description: Text("Tap Scan Receipt to begin."))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .navigationTitle("Scan")
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera) { image in
                    Task { await process(image: image) }
                }
            }
            .alert("Recognition Failed", isPresented: .constant(errorMessage != nil), actions: {
                Button("OK") { errorMessage = nil }
            }, message: {
                Text(errorMessage ?? "Unknown error")
            })
        }
    }

    @MainActor
    private func process(image: UIImage) async {
        isProcessing = true
        defer { isProcessing = false }
        do {
            let lines = try await TextRecognizer.recognizeLines(in: image)
            lastLines = lines
            store.add(lines: lines)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ScanView()
        .environmentObject(ReceiptStore())
}

