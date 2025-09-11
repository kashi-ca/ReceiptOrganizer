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

    init(id: UUID = UUID(), date: Date = Date(), lines: [String]) {
        self.id = id
        self.date = date
        self.lines = lines
    }
}

extension ReceiptRecord {
    /// Converts to the domain `Receipt` value type.
    func toDomain() -> Receipt {
        Receipt(id: id, date: date, lines: lines)
    }
}

