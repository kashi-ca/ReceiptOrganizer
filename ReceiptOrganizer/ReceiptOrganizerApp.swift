//
//  ReceiptOrganizerApp.swift
//  ReceiptOrganizer
//
//  Created by Victor Tai on 2025-08-29.
//

import SwiftUI
import SwiftData

@main
/// Application entry point.
struct ReceiptOrganizerApp: App {
    private let container: ModelContainer
    @StateObject private var store: ReceiptStore

    init() {
        do {
            // Create a local container first to avoid capturing self during StateObject init
            let localContainer = try ModelContainer(for: ReceiptRecord.self)
            _store = StateObject(wrappedValue: ReceiptStore(modelContext: localContainer.mainContext))
            self.container = localContainer
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .modelContainer(container)
    }
}
