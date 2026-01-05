// 1. File name: LanguageManager.swift
// 2. Version: 1.0
// 3. Date and time: Jan 5, 2026, 11:30 AM (IST)
// 4. Target for this file: Aro-CLI
// 5. Purpose of this file: Loads JSON translation files from PetAssets and provides translated strings to the UI.

import Foundation
import Combine

class LanguageManager: ObservableObject {
    // This makes the Translator available everywhere in the app
    static let shared = LanguageManager()
    
    // This holds all the words from the JSON file
    @Published var translations: [String: String] = [:]
    @Published var currentLanguage: String = "en"
    
    init() {
        // We start with English, but you can change this to "hi" or "de"
        loadLanguage(currentLanguage)
    }
    
    func loadLanguage(_ langCode: String) {
        self.currentLanguage = langCode
        
        // This looks inside your Blue folder: PetAssets/Localization/en.json
        let fileName = "PetAssets/Localization/\(langCode)"
        
        // 1. Find the file
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("❌ Error: Could not find \(fileName).json in Blue folder!")
            return
        }
        
        // 2. Read the file
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            // 3. Extract the "Translations" section
            if let transDict = json?["Translations"] as? [String: String] {
                DispatchQueue.main.async {
                    self.translations = transDict
                }
            }
        } catch {
            print("❌ Error: Failed to parse JSON: \(error)")
        }
    }
    
    // This is the function we use in the UI: lang.get("Btn_Save")
    func get(_ key: String) -> String {
        return translations[key] ?? "[\(key)]" // Returns [KEY] if missing
    }
}
