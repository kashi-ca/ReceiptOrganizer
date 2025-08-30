//
//  ReceiptOrganizerApp.swift
//  ReceiptOrganizer
//
//  Created by Victor Tai on 2025-08-29.
//

import SwiftUI

@main
/// Application entry point.
struct ReceiptOrganizerApp: App {
    @StateObject private var store = ReceiptStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
