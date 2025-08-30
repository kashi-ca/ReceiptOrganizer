import SwiftUI

struct ScanView: View {
    @EnvironmentObject private var store: ReceiptStore
    @State private var showCamera = false
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var savedMessageVisible = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Scan a receipt using your camera. Lines will be extracted with on‑device OCR.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button(action: {
                    if AppConfig.useLocalSampleReceipt {
                        Task { await processSample() }
                    } else {
                        showCamera = true
                    }
                }) {
                    Label("Scan Receipt", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)

                if isProcessing {
                    ProgressView("Recognizing text…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                ContentUnavailableView("Ready to scan", systemImage: "doc.text.viewfinder", description: Text("Results are saved to History."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(isProcessing ? 0.4 : 1)

                if savedMessageVisible {
                    Label("Saved to History", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .transition(.opacity)
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
            store.add(lines: lines)
            showSavedMessageTemporarily()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func processSample() async {
        isProcessing = true
        defer { isProcessing = false }
        let image = SampleImageProvider.sampleReceiptImage()
        do {
            let lines = try await TextRecognizer.recognizeLines(in: image)
            store.add(lines: lines)
            showSavedMessageTemporarily()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func showSavedMessageTemporarily() {
        withAnimation { savedMessageVisible = true }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            withAnimation { savedMessageVisible = false }
        }
    }
}

#Preview {
    ScanView()
        .environmentObject(ReceiptStore())
}
