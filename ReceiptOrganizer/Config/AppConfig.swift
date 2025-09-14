import Foundation

/// App-wide feature flags and configuration values.
enum AppConfig {
    /// If true, use a bundled/local sample image for OCR instead of the photo picker.
    /// Set to `false` to select from the photo library.
    static let useLocalSampleReceipt: Bool = true
}
