import Foundation

/// App-wide feature flags and configuration values.
enum AppConfig {
    /// If true, use a bundled/local sample image for OCR instead of the camera.
    /// Set to `false` to capture using the device camera.
    static let useLocalSampleReceipt: Bool = true
}
