import SwiftUI

/// Shows summary details for a specific receipt. Only displays lines containing "Total"
/// (case-insensitive) while excluding variants of "Subtotal". Use the menu to view all lines.
struct ReceiptDetailView: View {
    let receipt: Receipt

    private var totalLines: [String] {
        receipt.lines.filter { line in
            let lower = line.lowercased()
            let normalized = lower.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
            return normalized.contains("total") && !normalized.contains("subtotal")
        }
    }

    var body: some View {
        List {
            if totalLines.isEmpty {
                Section("Totals") {
                    Text("No totals found")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("Totals") {
                    ForEach(totalLines, id: \.self) { line in
                        Text(line)
                            .textSelection(.enabled)
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
                        ReceiptDetailsView(receipt: receipt)
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
