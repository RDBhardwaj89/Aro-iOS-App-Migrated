// 1. File name: Aro_CLIApp.swift
// 2. Version: 36.0
// 3. Date and time: Jan 9, 2026, 11:45 AM (IST)
// 4. Target for this file: Aro-CLI
// 5. Purpose: App entry point with a professional database reset mechanism.

import SwiftUI
import SwiftData

@main
struct Aro_CLIApp: App {
    // 🛠 SET THIS TO TRUE ONCE, THEN FALSE
    let shouldResetDatabase = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PetModel.self, SpeciesMetadata.self, AnimationMetadata.self, FoodMetadata.self, DietMetadata.self]) { result in
            if case .success = result {
                if shouldResetDatabase {
                    wipeDatabaseFiles()
                    print("🧹 [PRO] Version 36.0 Sync: Database Wiped Successfully.")
                }
            }
        }
    }

    private func wipeDatabaseFiles() {
        let url = URL.libraryDirectory.appendingPathComponent("Application Support")
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for file in files where file.lastPathComponent.contains("default.store") {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("❌ Failed wipe: \(error)")
        }
    }
}
