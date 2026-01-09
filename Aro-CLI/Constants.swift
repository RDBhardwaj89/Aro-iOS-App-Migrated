// 1. File name: Constants.swift
// 2. Version: 45.0
// 3. Date and time: Jan 9, 2026, 12:45 PM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Global named constants for Category and Speed to ensure type-safe metadata seeding.

import Foundation

struct PetConstants {
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
