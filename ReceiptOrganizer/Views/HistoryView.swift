import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: ReceiptStore

    var body: some View {
        NavigationStack {
            Group {
                if store.receipts.isEmpty {
                    ContentUnavailableView("No receipts yet", systemImage: "clock.arrow.circlepath", description: Text("Scans you complete will appear here."))
                } else {
                    List {
                        ForEach(store.receipts) { receipt in
                            NavigationLink(value: receipt) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(receipt.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    Text(receipt.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationDestination(for: Receipt.self) { receipt in
                ReceiptDetailView(receipt: receipt)
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(ReceiptStore())
}

