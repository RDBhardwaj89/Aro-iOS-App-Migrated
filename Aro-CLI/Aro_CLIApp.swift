// 1. File name: Aro_CLIApp.swift
// 2. Version: 64.0
// 3. Date and time: Jan 11, 2026, 05:45 PM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Professional entry point. Uses explicit Local Configuration to fix iPad Sandbox errors.

import SwiftUI
import SwiftData

@main
struct Aro_CLIApp: App {
    // This is the only @main allowed in the app!
    
    let container: ModelContainer

    init() {
        do {
            // 🛠 FORCE LOCAL STORAGE: This is the fix for the Sandbox errors in your log
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(
                for: PetModel.self,
                SpeciesMetadata.self,
                AnimationMetadata.self,
                FoodMetadata.self,
                DietMetadata.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
