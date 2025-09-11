//
//  ContentView.swift
//  ReceiptOrganizer
//
//  Created by Victor Tai on 2025-08-29.
//

import SwiftUI
import SwiftData

/// Root view hosting the Scan and History tabs.
struct ContentView: View {
    @EnvironmentObject private var store: ReceiptStore

    var body: some View {
        TabView {
            ScanView()
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }

            HistoryView()
                .tabItem { Label("History", systemImage: "doc.text.magnifyingglass") }
        }
    }
}

#Preview {
    // In-memory SwiftData container for previews
    do {
        let container = try ModelContainer(for: ReceiptRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return ContentView()
            .modelContainer(container)
            .environmentObject(ReceiptStore(modelContext: container.mainContext))
    } catch {
        return ContentView()
            .environmentObject(ReceiptStore(modelContext: try! ModelContainer(for: ReceiptRecord.self).mainContext))
    }
}
