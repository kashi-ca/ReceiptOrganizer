//
//  ContentView.swift
//  ReceiptOrganizer
//
//  Created by Victor Tai on 2025-08-29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ReceiptStore

    private enum TabSelection: Hashable {
        case scan, history
    }

    @State private var selectedTab: TabSelection = .scan

    var body: some View {
        TabView(selection: $selectedTab) {
            ScanView(onScanComplete: { selectedTab = .history })
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
                .tag(TabSelection.scan)

            HistoryView()
                .tabItem { Label("History", systemImage: "doc.text.magnifyingglass") }
                .tag(TabSelection.history)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ReceiptStore())
}
