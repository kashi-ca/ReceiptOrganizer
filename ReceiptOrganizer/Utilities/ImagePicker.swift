import SwiftUI
import UIKit

/// SwiftUI wrapper for `UIImagePickerController` to capture or select a photo.
struct ImagePicker: UIViewControllerRepresentable {
    /// The source type to use (camera by default; falls back to photo library if unavailable).
    var sourceType: UIImagePickerController.SourceType = .camera
    /// Callback with the selected/captured image.
    var onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    /// Creates the coordinator to bridge UIKit delegate callbacks.
    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, dismiss: dismiss)
    }

    /// Configures and returns the underlying `UIImagePickerController`.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    /// No updates needed after creation.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    /// Coordinator that forwards delegate events to SwiftUI closures.
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        let dismiss: DismissAction

        init(onImagePicked: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImagePicked = onImagePicked
            self.dismiss = dismiss
        }

        /// Handles successful capture/selection and dismisses the picker.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            dismiss()
        }

        /// Handles cancellation.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
