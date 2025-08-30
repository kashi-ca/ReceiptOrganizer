import Foundation
import Combine

/// Observable store for scanned receipts with simple UserDefaults persistence.
final class ReceiptStore: ObservableObject {
    /// Receipts ordered newest-first.
    @Published private(set) var receipts: [Receipt] = []

    private let storageKey = "receiptsStorage.v1"

    /// Initializes the store and loads any persisted receipts.
    init() {
        load()
    }

    /// Adds a new receipt from raw recognized lines.
    /// - Parameter lines: Raw OCR lines; empty/whitespace-only lines are discarded.
    func add(lines: [String]) {
        let cleaned = lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !cleaned.isEmpty else { return }
        receipts.insert(Receipt(lines: cleaned), at: 0)
        save()
    }

    /// Removes receipts at the given offsets (used by List deletions).
    /// - Parameter offsets: Index set from SwiftUI `List.onDelete`.
    func remove(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            if receipts.indices.contains(index) {
                receipts.remove(at: index)
            }
        }
        save()
    }

    /// Removes a specific receipt if it exists.
    /// - Parameter receipt: The receipt to delete.
    func delete(_ receipt: Receipt) {
        if let idx = receipts.firstIndex(where: { $0.id == receipt.id }) {
            receipts.remove(at: idx)
            save()
        }
    }

    /// Clears all stored receipts.
    func clear() {
        receipts.removeAll()
        save()
    }

    /// Persists the receipts array into UserDefaults.
    private func save() {
        do {
            let data = try JSONEncoder().encode(receipts)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save receipts: \(error)")
        }
    }

    /// Loads persisted receipts from UserDefaults, if available.
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            receipts = try JSONDecoder().decode([Receipt].self, from: data)
        } catch {
            print("Failed to load receipts: \(error)")
            receipts = []
        }
    }
}
