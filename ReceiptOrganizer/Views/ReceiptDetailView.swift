import SwiftUI

/// Shows summary details for a specific receipt. Only displays lines containing "Total"
/// (case-insensitive) while excluding variants of "Subtotal". Use the menu to view all lines.
struct ReceiptDetailView: View {
    let receipt: Receipt

    private func norm(_ s: String) -> String {
        s.lowercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
    }

    private var totalLines: [String] {
        receipt.totalItems
    }

    private var subtotalLines: [String] {
        receipt.subtotalItems
    }

    private var taxLines: [String] {
        receipt.typedLines.map { $0.text }.filter { norm($0).contains("tax") }
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
