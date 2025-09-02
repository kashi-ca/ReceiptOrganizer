import Foundation
import Vision
import UIKit

/// Errors thrown by `TextRecognizer`.
enum TextRecognitionError: Error {
    /// The provided image could not produce a `CGImage` for Vision.
    case cgImageUnavailable
    case cannotProcessImage
}

/// Thin async wrapper around Vision to recognize text lines from a `UIImage`.
struct TextRecognizer {
    struct Line {
        let text: String
        let yBounds: Double
    }
    /// Performs on-device OCR and returns the best candidate string for each line.
    /// - Parameters:
    ///   - image: Source image to analyze.
    ///   - languages: BCP-47 language codes prioritized for recognition (default: en_US).
    /// - Returns: An array of recognized lines in reading order.
    /// - Throws: Any `VNImageRequestHandler`/Vision error, or `TextRecognitionError`.
    static func recognizeLines(in image: UIImage, languages: [String] = ["en_US"]) async throws -> [String] {
        guard let cgImage = image.cgImage else { throw TextRecognitionError.cgImageUnavailable }

        var request = RecognizeTextRequest()
        request.automaticallyDetectsLanguage = true
        request.usesLanguageCorrection = true
        request.recognitionLanguages = languages.map { .init(identifier: $0) }

        let results = try await request.perform(on: cgImage)
        let lines = results.map { observationResult in
            observationResult.topCandidates(1).first?.string
        }

        return []
    }
}
