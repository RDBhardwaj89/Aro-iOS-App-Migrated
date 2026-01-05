// 1. File name: PetModel.swift
// 2. Version: 1.2
// 3. Date and time: Jan 5, 2026, 12:10 PM (IST)
// 4. Target for this file: Aro-CLI
// 5. Purpose of this file: Persistent data model for the pet.

import Foundation
import SwiftData

@Model
class PetModel {
    var name: String
    var scale: Double
    var speedId: Int
    var physicsMode: Int
    var screenEdgeMode: Int
    
    init(name: String = "Aro", scale: Double = 1.0, speedId: Int = 4, physicsMode: Int = 0, screenEdgeMode: Int = 1) {
        self.name = name
        self.scale = scale
        self.speedId = speedId
        self.physicsMode = physicsMode
        self.screenEdgeMode = screenEdgeMode
    }
}
