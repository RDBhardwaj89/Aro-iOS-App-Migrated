// 1. File name: Constants.swift
// 2. Version: 17.0
// 3. Date and time: Jan 8, 2026, 11:20 AM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Global constants and Enums for Category and Speed matching C# parity.

import Foundation

struct PetConstants {
    enum Category: Int {
        case inactive = 0
        case neutral = 1
        case active = 2
    }
    
    struct Speed {
        static let stop: Double = 0
        static let crawl: Double = 1
        static let walk: Double = 3
        static let fast: Double = 6
        static let jump: Double = 9
        static let fly: Double = 12
    }
}
