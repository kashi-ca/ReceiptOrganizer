import SwiftUI
import SwiftData

/// Shows summary details for a specific receipt. Only displays lines containing "Total"
/// (case-insensitive) while excluding variants of "Subtotal". Use the menu to view all lines.
struct ReceiptDetailView: View {
    let receipt: Receipt
    @EnvironmentObject private var store: ReceiptStore
    @State private var isEditing = false
    @State private var storeNameText = ""
    @State private var dateSelection = Date()
    @State private var showDatePicker = false
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

    /// Tries to extract a date-like substring from the raw OCR lines.
    /// Supports common formats like MM/DD/YYYY, DD/MM/YYYY, YYYY-MM-DD, and "Jan 2, 2024".
    private var extractedDateText: String? {
        let patterns: [String] = [
            #"\b(?:0?[1-9]|1[0-2])[/-](?:0?[1-9]|[12][0-9]|3[01])[/-](?:20\d{2}|\d{2})\b"#, // MM/DD/YYYY or MM/DD/YY
            #"\b(?:0?[1-9]|[12][0-9]|3[01])[/-](?:0?[1-9]|1[0-2])[/-](?:20\d{2}|\d{2})\b"#, // DD/MM/YYYY or DD/MM/YY
            #"\b20\d{2}[-/](?:0?[1-9]|1[0-2])[-/](?:0?[1-9]|[12][0-9]|3[01])\b"#,            // YYYY-MM-DD or YYYY/MM/DD
            #"\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{2,4}\b"# // Month name day, year
        ]
        for raw in liveReceipt.lines {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                    let ns = line as NSString
                    let range = NSRange(location: 0, length: ns.length)
                    if let match = regex.firstMatch(in: line, options: [], range: range) {
                        return ns.substring(with: match.range)
                    }
                }
            }
        }
        return nil
    }

    /// Parses a textual date into a Date using several common formats.
    private func parseDate(from text: String) -> Date? {
        let fmts = [
            "M/d/yy", "M/d/yyyy", "MM/dd/yy", "MM/dd/yyyy",
            "d/M/yy", "d/M/yyyy", "dd/MM/yy", "dd/MM/yyyy",
            "yyyy-MM-dd", "yyyy/MM/dd",
            "MMM d, yyyy", "MMMM d, yyyy", "MMM d, yy"
        ]
        for f in fmts {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(secondsFromGMT: 0)
            df.dateFormat = f
            if let d = df.date(from: text) { return d }
        }
        return nil
    }

    private var extractedDate: Date? {
        guard let s = extractedDateText else { return nil }
        return parseDate(from: s)
    }

    private func loadEditorDefaults() {
        storeNameText = liveReceipt.editedStoreName ?? liveReceipt.title
        dateSelection = liveReceipt.editedDate ?? extractedDate ?? liveReceipt.date
        showDatePicker = false
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
                if isEditing {
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack {
                                Text("Date")
                                Spacer()
                                Text(dateSelection.formatted(date: .abbreviated, time: .omitted))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())

                        if showDatePicker {
                            DatePicker("", selection: $dateSelection, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.graphical)
                        }
                    }
                } else {
                    HStack {
                        Text("Date")
                        Spacer()
                        Text((liveReceipt.editedDate ?? extractedDate ?? liveReceipt.date).formatted(date: .abbreviated, time: .omitted))
                            .foregroundStyle((liveReceipt.editedDate != nil || extractedDate != nil) ? .primary : .secondary)
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
                                date: dateSelection,
                                subtotal: sub.isEmpty ? nil : sub,
                                tax: tax.isEmpty ? nil : tax,
                                total: tot.isEmpty ? nil : tot
                            )
                            isEditing = false
                            showDatePicker = false
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
