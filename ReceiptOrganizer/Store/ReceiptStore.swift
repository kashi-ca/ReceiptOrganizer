import Foundation
import Combine

final class ReceiptStore: ObservableObject {
    @Published private(set) var receipts: [Receipt] = []

    private let storageKey = "receiptsStorage.v1"

    init() {
        load()
    }

    func add(lines: [String]) {
        let cleaned = lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !cleaned.isEmpty else { return }
        receipts.insert(Receipt(lines: cleaned), at: 0)
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(receipts)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save receipts: \(error)")
        }
    }

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

