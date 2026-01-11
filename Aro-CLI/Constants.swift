// 1. File name: Constants.swift
// 2. Version: 62.0
// 3. Date and time: Jan 10, 2026, 01:15 PM (IST)
// 4. Target group: Aro-CLI & AroWidgetExtension
// 5. Purpose: Global constants and shared data models for multi-pet widget synchronization.

import Foundation

struct PetConstants {
    static let appGroup = "group.com.BrainBliss.Aro-CLI"
    static let suiteKey = "activePetsList"
    
    struct Category {
        static let inactive: Int = 0
        static let neutral: Int = 1
        static let active: Int = 2
    }
    
    struct Speed {
        static let stop: Double = 0.0
        static let crawl: Double = 1.0
        static let walk: Double = 3.0
        static let fast: Double = 6.0
        static let jump: Double = 9.0
        static let fly: Double = 12.0
    }
}

struct WidgetPetStatus: Codable {
    let id: UUID
    let name: String
    let hunger: Double
    let speciesId: Int
    let iconPath: String
}
