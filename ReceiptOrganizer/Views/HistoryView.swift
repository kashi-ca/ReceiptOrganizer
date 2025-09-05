import SwiftUI

/// Displays previously scanned receipts and allows deletion.
struct HistoryView: View {
    @EnvironmentObject private var store: ReceiptStore
    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if store.receipts.isEmpty {
                    ContentUnavailableView("No receipts yet", systemImage: "clock.arrow.circlepath", description: Text("Scans you complete will appear here."))
                } else {
                    List {
                        ForEach(store.receipts) { receipt in
                            NavigationLink(value: receipt) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(receipt.title)
                                            .font(.headline)
                                            .lineLimit(1)
                                        Spacer()
                                        if let total = totalLine(for: receipt) {
                                            Text(total)
                                                .font(.subheadline)
                                                .lineLimit(1)
                                                .foregroundStyle(.primary)
                                                .accessibilityLabel("Total \(total)")
                                        }
                                    }
                                    Text(receipt.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("History")
            .navigationDestination(for: Receipt.self) { receipt in
                ReceiptDetailView(receipt: receipt)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !store.receipts.isEmpty {
                        Button(role: .destructive) { showClearAlert = true } label: {
                            Label("Clear", systemImage: "trash")
                        }
                        .accessibilityIdentifier("history.clearAll")
                    }
                }
            }
            .alert("Clear all history?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All", role: .destructive) { store.clear() }
            } message: {
                Text("This removes all scanned receipts.")
            }
        }
    }

    /// Extracts the most relevant total line for display, excluding 'Subtotal'.
    private func totalLine(for receipt: Receipt) -> String? {
        let filtered = receipt.lines.filter { line in
            let lower = line.lowercased()
            let normalized = lower.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
            return normalized.contains("total") && !normalized.contains("subtotal")
        }
        return filtered.last
    }

    /// Handles swipe-to-delete for rows in the list.
    /// - Parameter offsets: Indexes provided by `List.onDelete`.
    private func delete(_ offsets: IndexSet) {
        store.remove(at: offsets)
    }
}

#Preview {
    HistoryView()
        .environmentObject(ReceiptStore())
}
