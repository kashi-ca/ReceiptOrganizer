import SwiftUI
import SwiftData

/// Shows summary details for a specific receipt. Only displays lines containing "Total"
/// (case-insensitive) while excluding variants of "Subtotal". Use the menu to view all lines.
struct ReceiptDetailView: View {
    let receipt: Receipt
    @EnvironmentObject private var store: ReceiptStore
    @State private var isEditing = false
    @State private var storeNameText = ""
    @State private var subtotalText = ""
    @State private var taxText = ""
    @State private var totalText = ""

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

    /// Resolves the latest copy of the receipt from the store (by id).
    private var liveReceipt: Receipt {
        store.receipts.first(where: { $0.id == receipt.id }) ?? receipt
    }

    private var totalLines: [String] {
        liveReceipt.totalItems
            .map { numberPreservingDecimal($0) }
            .filter { !$0.isEmpty }
    }

    private var subtotalLines: [String] {
        liveReceipt.subtotalItems
            .map { numberPreservingDecimal($0) }
            .filter { !$0.isEmpty }
    }

    // Tax lines are temporarily hidden per request.

    private func normalizedKey(_ s: String) -> String {
        s.lowercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
    }

    private var extractedSubtotal: String? { subtotalLines.last }
    private var extractedTotal: String? { totalLines.last }
    private var extractedTax: String? {
        let taxCandidates = liveReceipt.typedLines.map { $0.text }.filter { normalizedKey($0).contains("tax") }
        let compacted = taxCandidates.map { numberPreservingDecimal($0) }.filter { !$0.isEmpty }
        return compacted.last
    }

    private func loadEditorDefaults() {
        storeNameText = liveReceipt.editedStoreName ?? liveReceipt.title
        subtotalText = liveReceipt.editedSubtotal ?? extractedSubtotal ?? ""
        taxText = liveReceipt.editedTax ?? extractedTax ?? ""
        totalText = liveReceipt.editedTotal ?? extractedTotal ?? ""
    }

    var body: some View {
        List {
            if liveReceipt.isEdited {
                Section {
                    Label("Edited", systemImage: "pencil.circle.fill")
                        .foregroundStyle(.tint)
                        .font(.subheadline)
                        .accessibilityIdentifier("receipt.editedBadge")
                }
            }

            Section("Summary") {
                HStack {
                    Text("Store")
                    Spacer()
                    if isEditing {
                        TextField("Store Name", text: $storeNameText)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                    } else {
                        Text(liveReceipt.editedStoreName ?? liveReceipt.title)
                            .foregroundStyle((liveReceipt.editedStoreName != nil) ? .primary : .secondary)
                    }
                }
                HStack {
                    Text("Subtotal")
                    Spacer()
                    if isEditing {
                        TextField("Subtotal", text: $subtotalText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    } else {
                        Text(liveReceipt.editedSubtotal ?? extractedSubtotal ?? "—")
                            .foregroundStyle((liveReceipt.editedSubtotal != nil) ? .primary : .secondary)
                    }
                }
                HStack {
                    Text("Tax")
                    Spacer()
                    if isEditing {
                        TextField("Tax", text: $taxText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    } else {
                        Text(liveReceipt.editedTax ?? extractedTax ?? "—")
                            .foregroundStyle((liveReceipt.editedTax != nil) ? .primary : .secondary)
                    }
                }
                HStack {
                    Text("Total")
                    Spacer()
                    if isEditing {
                        TextField("Total", text: $totalText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    } else {
                        Text(liveReceipt.editedTotal ?? extractedTotal ?? "—")
                            .foregroundStyle((liveReceipt.editedTotal != nil) ? .primary : .secondary)
                    }
                }
            }

            // Additional detail sections removed; Summary shows key values.
        }
        .navigationTitle("Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if liveReceipt.isEdited && !isEditing {
                    Button {
                        store.clearEdits(for: liveReceipt.id)
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }
                    .accessibilityIdentifier("receipt.undoEdits")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    if isEditing {
                        Button {
                            // Sanitize inputs and save
                            let sub = numberPreservingDecimal(subtotalText)
                            let tax = numberPreservingDecimal(taxText)
                            let tot = numberPreservingDecimal(totalText)
                            let storeName = storeNameText.trimmingCharacters(in: .whitespacesAndNewlines)
                            store.updateEdits(
                                for: liveReceipt.id,
                                storeName: storeName.isEmpty ? nil : storeName,
                                subtotal: sub.isEmpty ? nil : sub,
                                tax: tax.isEmpty ? nil : tax,
                                total: tot.isEmpty ? nil : tot
                            )
                            isEditing = false
                        } label: {
                            Text("Save")
                        }
                        .accessibilityIdentifier("receipt.saveEdits")
                    } else {
                        Button {
                            loadEditorDefaults()
                            isEditing = true
                        } label: {
                            Text("Edit")
                        }
                        .accessibilityIdentifier("receipt.edit")
                    }

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
}

#Preview {
    do {
        let container = try ModelContainer(for: ReceiptRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let store = ReceiptStore(modelContext: container.mainContext)
        let sample = Receipt(lines: [
            "Store Name",
            "Item 1   $1.99",
            "Item 2   $3.49",
            "Subtotal $5.48",
            "Total    $5.48"
        ])
        return NavigationStack { ReceiptDetailView(receipt: sample) }
            .modelContainer(container)
            .environmentObject(store)
    } catch {
        return NavigationStack { Text("Preview Error") }
    }
}
