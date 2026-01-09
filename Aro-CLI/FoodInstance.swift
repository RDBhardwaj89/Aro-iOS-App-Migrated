// 1. File name: FoodInstance.swift
// 2. Version: 39.0
// 3. Date and time: Jan 9, 2026, 12:00 PM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Data structure for dropped food with position tracking and claim-logic for pets.

import Foundation

struct FoodInstance: Identifiable, Equatable {
    let id: UUID = UUID()
    let foodId: Int
    let filename: String
    var x: CGFloat
    var y: CGFloat
    var isClaimed: Bool = false
}
