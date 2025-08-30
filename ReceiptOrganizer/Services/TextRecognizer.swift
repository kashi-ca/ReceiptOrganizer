import Foundation
import Vision
import UIKit

enum TextRecognitionError: Error {
    case cgImageUnavailable
}

struct TextRecognizer {
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

