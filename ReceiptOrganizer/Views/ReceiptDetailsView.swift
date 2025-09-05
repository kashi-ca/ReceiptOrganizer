import SwiftUI

/// Displays the complete set of recognized lines for a receipt.
struct ReceiptDetailsView: View {
    let receipt: Receipt

    var body: some View {
        List {
            Section("All Lines") {
                ForEach(receipt.lines, id: \.self) { line in
                    Text(line)
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle("Receipt Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReceiptDetailsView(
            receipt: Receipt(lines: [
                "Store Name",
                "Item 1   $1.99",
                "Item 2   $3.49",
                "Tax      $0.52",
                "Total    $5.48"
            ])
        )
    }
}
