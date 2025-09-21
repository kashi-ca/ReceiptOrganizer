import SwiftUI

/// Shows summary details for a specific receipt. Only displays lines containing "Total"
/// (case-insensitive) while excluding variants of "Subtotal". Use the menu to view all lines.
struct ReceiptDetailView: View {
    let receipt: Receipt

    // removed: compactNumericSpaces (replaced by numberPreservingDecimal)

    /// Normalizes a numeric string by removing currency symbols/spaces and preserving at most one decimal separator.
    private func numberPreservingDecimal(_ s: String) -> String {
        let t = s.replacingOccurrences(of: "$", with: "").filter { !$0.isWhitespace }
        if t.contains(".") {
            let lastDot = t.lastIndex(of: ".")
            var out = String()
            var idx = t.startIndex
            while idx < t.endIndex {
                let ch = t[idx]
                if ch.isNumber {
                    out.append(ch)
                } else if ch == ".", let lastDot, idx == lastDot {
                    out.append(".")
                }
                idx = t.index(after: idx)
            }
            return out
        } else if t.contains(",") {
            let lastComma = t.lastIndex(of: ",")
            var out = String()
            var idx = t.startIndex
            while idx < t.endIndex {
                let ch = t[idx]
                if ch.isNumber {
                    out.append(ch)
                } else if ch == ",", let lastComma, idx == lastComma {
                    out.append(".")
                }
                idx = t.index(after: idx)
            }
            return out
        } else {
            return t.filter { $0.isNumber }
        }
    }

    private var totalLines: [String] {
        receipt.totalItems
            .map { numberPreservingDecimal($0) }
            .filter { !$0.isEmpty }
    }

    private var subtotalLines: [String] {
        receipt.subtotalItems
            .map { numberPreservingDecimal($0) }
            .filter { !$0.isEmpty }
    }

    // Tax lines are temporarily hidden per request.

    var body: some View {
        List {
            if !subtotalLines.isEmpty {
                Section("Subtotal") {
                    ForEach(subtotalLines, id: \.self) { line in
                        Text(line).textSelection(.enabled)
                    }
                }
            }

            // Tax section intentionally removed

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
