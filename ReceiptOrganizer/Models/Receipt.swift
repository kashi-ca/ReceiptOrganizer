import Foundation

/// A single scanned receipt consisting of extracted text lines and metadata.
struct Receipt: Identifiable, Codable, Equatable, Hashable {
    /// Stable unique identifier for the receipt.
    let id: UUID
    /// Timestamp when the receipt was created/saved.
    let date: Date
    /// Ordered list of recognized text lines from OCR.
    let lines: [String]

    /// Creates a new receipt from recognized lines.
    /// - Parameters:
    ///   - id: Optional explicit identifier (defaults to a new UUID).
    ///   - date: Creation date (defaults to now).
    ///   - lines: Recognized text lines.
    init(id: UUID = UUID(), date: Date = Date(), lines: [String]) {
        self.id = id
        self.date = date
        self.lines = lines
    }

    /// A short title derived from the first non-empty line; falls back to "Receipt".
    var title: String {
        lines.first?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ?
            String(lines.first!) : "Receipt"
    }
}
