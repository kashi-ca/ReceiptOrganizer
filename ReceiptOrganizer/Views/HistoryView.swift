import SwiftUI
import SwiftData

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
                                        if let total = totalAmount(for: receipt) {
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
                            .tag(receipt.id)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.delete(receipt)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .accessibilityIdentifier("history.row.delete")
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
            let isTotalOrBalance = normalized.contains("total") || normalized.contains("balance")
            let isSubtotal = normalized.contains("subtotal")
            return isTotalOrBalance && !isSubtotal
        }
        return filtered.last
    }

    /// Returns just the amount portion from the total line, removing the word "Total" and punctuation.
    private func totalAmount(for receipt: Receipt) -> String? {
        guard let line = totalLine(for: receipt) else { return nil }
        if let currency = extractCurrency(from: line) {
            return currency
        }
        // Fallback: strip the leading "Total" label and punctuation
        return strippedTextAfterTotal(from: line)
    }

    /// Tries to find a currency-like token (e.g., "$7.02" or "7.02") in the string.
    private func extractCurrency(from text: String) -> String? {
        // Remove all whitespace to avoid spaces between digits from OCR
        let cleaned = text.filter { !$0.isWhitespace }
        let pattern = #"\$?[0-9]+(?:[.,][0-9]{2})?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let ns = cleaned as NSString
        let range = NSRange(location: 0, length: ns.length)
        let matches = regex.matches(in: cleaned, options: [], range: range)
        guard let last = matches.last else { return nil }
        let value = ns.substring(with: last.range)
        // Drop any leading dollar sign
        return value.replacingOccurrences(of: "$", with: "")
    }

    /// Removes the leading "Total" label and any following punctuation like ":" or "-".
    private func strippedTextAfterTotal(from text: String) -> String {
        var s = text
        if let r = s.range(of: "total", options: .caseInsensitive) {
            s = String(s[r.upperBound...])
        }
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        while let first = s.first, [":", "-", "="] .contains(first) {
            s.removeFirst()
            s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // Remove all whitespace to avoid spaces between digits from OCR
        var compact = s.filter { !$0.isWhitespace }
        if compact.first == "$" { compact.removeFirst() }
        return compact
    }

    /// Handles swipe-to-delete for rows in the list.
    /// - Parameter offsets: Indexes provided by `List.onDelete`.
    private func delete(_ offsets: IndexSet) {
        store.remove(at: offsets)
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: ReceiptRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return HistoryView()
            .modelContainer(container)
            .environmentObject(ReceiptStore(modelContext: container.mainContext))
    } catch {
        return HistoryView()
            .environmentObject(ReceiptStore(modelContext: try! ModelContainer(for: ReceiptRecord.self).mainContext))
    }
}
