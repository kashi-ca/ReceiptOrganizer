//
//  ContentView.swift
//  ReceiptOrganizer
//
//  Created by Victor Tai on 2025-08-29.
//

import SwiftUI

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
    ContentView()
        .environmentObject(ReceiptStore())
}
