import Foundation
import Combine
import SwiftData

/// Observable store for scanned receipts persisted with SwiftData.
@MainActor
final class ReceiptStore: ObservableObject {
    /// Receipts ordered newest-first (domain models).
    @Published private(set) var receipts: [Receipt] = []

    private let modelContext: ModelContext
    /// Backing SwiftData records aligned with `receipts` by index.
    private var records: [ReceiptRecord] = []

    /// Initializes the store and loads receipts from SwiftData.
    /// - Parameter modelContext: The SwiftData model context used for persistence.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        load()
    }

    /// Adds a new receipt from raw recognized lines.
    /// - Parameter lines: Raw OCR lines; empty/whitespace-only lines are discarded.
    func add(lines: [String]) {
        let cleaned = lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !cleaned.isEmpty else { return }

        let record = ReceiptRecord(lines: cleaned)
        modelContext.insert(record)
        do {
            try modelContext.save()
            records.insert(record, at: 0)
            receipts.insert(record.toDomain(), at: 0)
        } catch {
            print("Failed to save receipt: \(error)")
        }
    }

    /// Removes receipts at the given offsets (used by List deletions).
    /// - Parameter offsets: Index set from SwiftUI `List.onDelete`.
    func remove(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            guard records.indices.contains(index) else { continue }
            let record = records[index]
            modelContext.delete(record)
            records.remove(at: index)
            receipts.remove(at: index)
        }
        do { try modelContext.save() } catch { print("Failed to delete receipts: \(error)") }
    }

    /// Removes a specific receipt if it exists.
    /// - Parameter receipt: The receipt to delete.
    func delete(_ receipt: Receipt) {
        if let idx = receipts.firstIndex(where: { $0.id == receipt.id }) {
            modelContext.delete(records[idx])
            records.remove(at: idx)
            receipts.remove(at: idx)
            do { try modelContext.save() } catch { print("Failed to delete receipt: \(error)") }
        }
    }

    /// Clears all stored receipts.
    func clear() {
        for record in records {
            modelContext.delete(record)
        }
        records.removeAll()
        receipts.removeAll()
        do { try modelContext.save() } catch { print("Failed to clear receipts: \(error)") }
    }

    /// Loads persisted receipts from SwiftData.
    private func load() {
        do {
            let descriptor = FetchDescriptor<ReceiptRecord>(
                predicate: nil,
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            records = try modelContext.fetch(descriptor)
            receipts = records.map { $0.toDomain() }
        } catch {
            print("Failed to fetch receipts: \(error)")
            records = []
            receipts = []
        }
    }
}
