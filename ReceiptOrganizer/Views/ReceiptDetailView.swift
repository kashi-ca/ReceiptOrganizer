import SwiftUI

/// Shows summary details for a specific receipt. Only displays lines containing "Total"
/// (case-insensitive) while excluding variants of "Subtotal". Use the menu to view all lines.
struct ReceiptDetailView: View {
    let receipt: Receipt

    private func norm(_ s: String) -> String {
        s.lowercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
    }

    /// Compacts whitespace within numeric/currency tokens (e.g., "$7. 02" -> "$7.02").
    private func compactNumericSpaces(in text: String) -> String {
        let pattern = #"\$?[0-9][0-9\s\.,]*"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        var result = text
        var ns = result as NSString
        let range = NSRange(location: 0, length: ns.length)
        let matches = regex.matches(in: result, options: [], range: range)
        for m in matches.reversed() {
            let token = ns.substring(with: m.range)
            let compact = token.filter { !$0.isWhitespace }
            result = ns.replacingCharacters(in: m.range, with: compact)
            ns = result as NSString
        }
        return result
    }

    private var totalLines: [String] { receipt.totalItems.map { compactNumericSpaces(in: $0) } }

    private var subtotalLines: [String] { receipt.subtotalItems.map { compactNumericSpaces(in: $0) } }

    private var taxLines: [String] {
        receipt.typedLines.map { $0.text }.filter { norm($0).contains("tax") }.map { compactNumericSpaces(in: $0) }
    }

    var body: some View {
        List {
            if !subtotalLines.isEmpty {
                Section("Subtotal") {
                    ForEach(subtotalLines, id: \.self) { line in
                        Text(line).textSelection(.enabled)
                    }
                }
            }

            if !taxLines.isEmpty {
                Section("Tax") {
                    ForEach(taxLines, id: \.self) { line in
                        Text(line).textSelection(.enabled)
                    }
                }
            }

            if totalLines.isEmpty {
                Section("Total") {
                    Text("No total found").foregroundStyle(.secondary)
                }
            } else {
                Section("Total") {
                    ForEach(totalLines, id: \.self) { line in
                        Text(line).textSelection(.enabled)
                    }
                }
            }
        }
        .navigationTitle(receipt.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink {
                        ReceiptDetailLinesView(receipt: receipt)
                    } label: {
                        Label("Receipt Details", systemImage: "doc.text.magnifyingglass")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReceiptDetailView(
            receipt: Receipt(lines: [
                "Store Name",
                "Item 1   $1.99",
                "Item 2   $3.49",
                "Subtotal $5.48",
                "Total    $5.48"
            ])
        )
    }
}
