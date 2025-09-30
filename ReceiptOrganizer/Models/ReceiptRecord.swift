import Foundation
import SwiftData

/// SwiftData model representing a persisted receipt.
@Model
final class ReceiptRecord {
    /// Stable unique identifier matching the domain model.
    @Attribute(.unique) var id: UUID
    /// Timestamp when the receipt was created/saved.
    var date: Date
    /// Ordered list of recognized text lines from OCR.
    var lines: [String]
    /// User-edited override for subtotal amount (normalized string), optional.
    var editedSubtotal: String?
    /// User-edited override for tax amount (normalized string), optional.
    var editedTax: String?
    /// User-edited override for total amount (normalized string), optional.
    var editedTotal: String?

    init(id: UUID = UUID(), date: Date = Date(), lines: [String], editedSubtotal: String? = nil, editedTax: String? = nil, editedTotal: String? = nil) {
        self.id = id
        self.date = date
        self.lines = lines
        self.editedSubtotal = editedSubtotal
        self.editedTax = editedTax
        self.editedTotal = editedTotal
    }
}

extension ReceiptRecord {
    /// Converts to the domain `Receipt` value type.
    func toDomain() -> Receipt {
        Receipt(id: id, date: date, lines: lines, editedSubtotal: editedSubtotal, editedTax: editedTax, editedTotal: editedTotal)
    }
}
