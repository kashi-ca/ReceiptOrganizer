import Foundation
import Vision

/// Errors thrown by `TextRecognizer`.
enum TextRecognitionError: Error {
    /// The provided image could not produce a `CGImage` for Vision.
    case cgImageUnavailable
}

/// Thin async wrapper around Vision to recognize text lines from a `UIImage`.
struct TextRecognizer {
    /// Performs on-device OCR and returns strings grouped into visual lines by Y position.
    /// - Parameters:
    ///   - image: Source image to analyze.
    ///   - languages: BCP-47 language codes prioritized for recognition (default: en_US).
    /// - Returns: An array of recognized lines in reading order (top-to-bottom, left-to-right).
    /// - Throws: Any `VNImageRequestHandler`/Vision error, or `TextRecognitionError`.
    static func recognizeLines(in image: UIImage, languages: [String] = ["en_US"]) async throws -> [String] {
        guard let cgImage = image.cgImage else { throw TextRecognitionError.cgImageUnavailable }
        var request = RecognizeTextRequest()

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = languages.map { .init(identifier: $0)}

        let observations = try await request.perform(on: cgImage)

        // Use a vertical anchor from the bounding box. Here we choose the bottom (minY).
        struct Item { let text: String; let anchorY: CGFloat; let minX: CGFloat }
        let items: [Item] = observations.compactMap { obs in
            guard let best = obs.topCandidates(1).first else { return nil }
            let text = best.string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }
            let bb = obs.boundingBox

            // Anchor can be switched to bb.maxY (top) if preferred.
            return Item(text: text, anchorY: bb.origin.y, minX: bb.origin.x)
        }

        // Group items whose vertical midpoints are within a small threshold.
        let yThreshold: CGFloat = 0.01 // 2% of image height
        let sorted = items.sorted { $0.anchorY > $1.anchorY } // top-to-bottom

        var groups: [[Item]] = []
        var current: [Item] = []
        var currentY: CGFloat?
        for it in sorted {
            if let y = currentY, abs(it.anchorY - y) <= yThreshold {
                current.append(it)
                // update running average midY to make grouping robust
                let total = current.reduce(0) { $0 + $1.anchorY }
                currentY = total / CGFloat(current.count)
            } else {
                if !current.isEmpty { groups.append(current) }
                current = [it]
                currentY = it.anchorY
            }
        }
        if !current.isEmpty { groups.append(current) }

        // Within each group, sort left-to-right and join text segments.
        let lines: [String] = groups.map { group in
            group.sorted { $0.minX < $1.minX }.map { $0.text }.joined(separator: " ")
        }

        return lines
    }
}
