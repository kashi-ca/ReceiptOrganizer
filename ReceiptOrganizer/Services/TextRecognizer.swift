import Foundation
import Vision
import UIKit

/// Errors thrown by `TextRecognizer`.
enum TextRecognitionError: Error {
    /// The provided image could not produce a `CGImage` for Vision.
    case cgImageUnavailable
}

/// Thin async wrapper around Vision to recognize text lines from a `UIImage`.
struct TextRecognizer {
    /// Performs on-device OCR and returns the best candidate string for each line.
    /// - Parameters:
    ///   - image: Source image to analyze.
    ///   - languages: BCP-47 language codes prioritized for recognition (default: en_US).
    /// - Returns: An array of recognized lines in reading order.
    /// - Throws: Any `VNImageRequestHandler`/Vision error, or `TextRecognitionError`.
    static func recognizeLines(in image: UIImage, languages: [String] = ["en_US"]) async throws -> [String] {
        guard let cgImage = image.cgImage else { throw TextRecognitionError.cgImageUnavailable }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let results = (request.results as? [VNRecognizedTextObservation]) ?? []
                let lines: [String] = results.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: lines)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = languages

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
