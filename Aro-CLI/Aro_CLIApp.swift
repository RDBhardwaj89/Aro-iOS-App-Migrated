// 1. File name: Aro_CLIApp.swift
// 2. Version: 1.2
// 3. Date and time: Jan 5, 2026, 06:50 PM (IST)
// 4. Target for this file: Aro-CLI
// 5. Purpose of this file: Main entry point with SwiftData container setup.

import SwiftUI
import SwiftData

@main
struct Aro_CLIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PetModel.self)
    }
}
