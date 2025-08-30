import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt

    var body: some View {
        List {
            Section("Lines") {
                ForEach(receipt.lines, id: \.self) { line in
                    Text(line)
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle(receipt.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ReceiptDetailView(
        receipt: Receipt(lines: [
            "Store Name",
            "Item 1   $1.99",
            "Item 2   $3.49",
            "Total    $5.48"
        ])
    )
}

