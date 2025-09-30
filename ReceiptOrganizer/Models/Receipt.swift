import Foundation

/// A single scanned receipt consisting of extracted text lines and metadata.
struct Receipt: Identifiable, Codable, Equatable, Hashable {
    /// Stable unique identifier for the receipt.
    let id: UUID
    /// Timestamp when the receipt was created/saved.
    let date: Date
    /// Ordered list of recognized text lines from OCR.
    let lines: [String]
    /// Optional user-edited store name override.
    let editedStoreName: String?
    /// Optional user-edited overrides.
    let editedSubtotal: String?
    let editedTax: String?
    let editedTotal: String?

    /// Creates a new receipt from recognized lines.
    /// - Parameters:
    ///   - id: Optional explicit identifier (defaults to a new UUID).
    ///   - date: Creation date (defaults to now).
    ///   - lines: Recognized text lines.
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        lines: [String],
        editedStoreName: String? = nil,
        editedSubtotal: String? = nil,
        editedTax: String? = nil,
        editedTotal: String? = nil
    ) {
        self.id = id
        self.date = date
        self.lines = lines
        self.editedStoreName = editedStoreName
        self.editedSubtotal = editedSubtotal
        self.editedTax = editedTax
        self.editedTotal = editedTotal
    }

    /// A short title derived from the first non-empty line; falls back to "Receipt".
    var title: String {
        lines.first?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ?
            String(lines.first!) : "Receipt"
    }

    /// Indicates whether any user edits exist for this receipt.
    var isEdited: Bool {
        (editedStoreName?.isEmpty == false) ||
        (editedSubtotal?.isEmpty == false) ||
        (editedTax?.isEmpty == false) ||
        (editedTotal?.isEmpty == false)
    }

    // MARK: - Line Classification

    /// Classification of a receipt line.
    enum LineType: String, Codable, Equatable, Hashable {
        case normal
        case subtotal
        case total
    }

    /// A parsed line with derived classification and cleaned text.
    struct TypedLine: Equatable, Hashable, Codable {
        /// The original OCR line text.
        let original: String
        /// The cleaned text with labels like "Subtotal"/"Total" removed.
        let text: String
        /// The derived classification for this line.
        let type: LineType
    }

    /// Normalizes a string for matching (lowercased, no spaces/hyphens).
    private func normalizedKey(_ s: String) -> String {
        s.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
    }

    /// Returns the derived classification for a raw line based on keywords.
    private func classify(_ line: String) -> LineType {
        let key = normalizedKey(line)
        if key.contains("subtotal") { return .subtotal }
        if key.contains("total") || key.contains("balance") { return .total }
        return .normal
    }

    /// Removes the label (Subtotal/Total) and adjoining punctuation from a line and trims whitespace.
    private func strippedLabel(from line: String, type: LineType) -> String {
        let pattern: String
        switch type {
        case .subtotal:
            // sub total, sub-total, subtotal with optional trailing punctuation
            pattern = "(?i)\\bsub\\s*-?\\s*total\\b\\s*[:\\-=]*\\s*"
        case .total:
            // total or balance with optional trailing punctuation
            pattern = "(?i)\\b(?:total|balance)\\b\\s*[:\\-=]*\\s*"
        case .normal:
            return line.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return line.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let ns = line as NSString
        let range = NSRange(location: 0, length: ns.length)
        let cleaned = regex.stringByReplacingMatches(in: line, options: [], range: range, withTemplate: "")
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Lines parsed into typed entries with labels removed where applicable.
    var typedLines: [TypedLine] {
        lines.map { raw in
            let t = classify(raw)
            let cleaned = strippedLabel(from: raw, type: t)
            return TypedLine(original: raw, text: cleaned, type: t)
        }
    }

    /// Convenience: cleaned texts for subtotal lines.
    var subtotalItems: [String] { typedLines.filter { $0.type == .subtotal }.map { $0.text } }
    /// Convenience: cleaned texts for total lines.
    var totalItems: [String] { typedLines.filter { $0.type == .total }.map { $0.text } }
}
