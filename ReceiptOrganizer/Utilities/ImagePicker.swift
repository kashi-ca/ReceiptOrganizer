import SwiftUI
import PhotosUI
import CoreGraphics
import ImageIO

/// SwiftUI-native image picker using `PhotosPicker`.
/// Presents a simple UI to select an image from the photo library and
/// returns a `CGImage` via the `onImagePicked` callback.
struct ImagePicker: View {
    /// Callback with the selected image.
    var onImagePicked: (CGImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                PhotosPicker(selection: $selectedItem, matching: .images, preferredItemEncoding: .automatic) {
                    Label("Choose Photo", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                if isLoading {
                    ProgressView("Loading…")
                        .controlSize(.large)
                }

                Text("Select a receipt image from your photo library.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Select Photo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onChange(of: selectedItem) { newItem in
            if let item = newItem { Task { await loadImage(from: item) } }
        }
    }

    @MainActor
    private func loadImage(from item: PhotosPickerItem) async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                if let source = CGImageSourceCreateWithData(data as CFData, nil),
                   let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
                    onImagePicked(cgImage)
                    dismiss()
                    return
                }
            }
        } catch {
            // Silently fail; caller will remain on picker UI
        }
    }
}
