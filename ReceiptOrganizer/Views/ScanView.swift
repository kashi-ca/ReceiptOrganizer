import SwiftUI
import SwiftData

/// Screen for capturing a receipt image and performing OCR.
struct ScanView: View {
    @EnvironmentObject private var store: ReceiptStore
    @State private var showCamera = false
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var savedMessageVisible = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen transparent background to keep layout stable
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Centered progress overlay
                if isProcessing {
                    ProgressView("Recognizing text…")
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Saved confirmation overlay (bottom)
                if savedMessageVisible {
                    Label("Saved to History", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 32)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Scan")
            .safeAreaInset(edge: .top) {
                VStack(spacing: 12) {
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
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
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

    /// Runs OCR against a captured image and saves a new receipt.
    /// - Parameter image: The image to process.
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

    /// Generates/loads a sample image, performs OCR, and saves a new receipt.
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

    /// Briefly displays a confirmation message indicating the receipt was saved.
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
    do {
        let container = try ModelContainer(for: ReceiptRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return ScanView()
            .modelContainer(container)
            .environmentObject(ReceiptStore(modelContext: container.mainContext))
    } catch {
        return ScanView()
            .environmentObject(ReceiptStore(modelContext: try! ModelContainer(for: ReceiptRecord.self).mainContext))
    }
}
