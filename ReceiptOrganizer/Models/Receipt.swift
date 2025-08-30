import Foundation

struct Receipt: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let date: Date
    let lines: [String]

    init(id: UUID = UUID(), date: Date = Date(), lines: [String]) {
        self.id = id
        self.date = date
        self.lines = lines
    }

    var title: String {
        lines.first?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ?
            String(lines.first!) : "Receipt"
    }
}
