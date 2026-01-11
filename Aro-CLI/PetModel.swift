// 1. File name: PetModel.swift
// 2. Version: 52.0
// 3. Date and time: Jan 10, 2026, 10:30 AM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Professional relational schema for persistent pet and metadata storage.

import Foundation
import SwiftData

@Model
class SpeciesMetadata {
    @Attribute(.unique) var speciesId: Int
    var name: String
    var basePath: String
    var startAnimation: String
    var defaultName: String
    var iconPath: String
    @Relationship(deleteRule: .cascade) var animations: [AnimationMetadata] = []
    
    init(id: Int, name: String, path: String, start: String, defName: String, icon: String) {
        self.speciesId = id
        self.name = name
        self.basePath = path
        self.startAnimation = start
        self.defaultName = defName
        self.iconPath = icon
    }
}

@Model
class AnimationMetadata {
    var speciesId: Int
    var name: String
    var folderName: String
    var frameCount: Int
    var baseSpeedX: Double
    var category: Int
    var minLoops: Int
    var maxLoops: Int
    
    init(speciesId: Int, name: String, folder: String, frames: Int, speed: Double, cat: Int, minL: Int, maxL: Int) {
        self.speciesId = speciesId
        self.name = name
        self.folderName = folder
        self.frameCount = frames
        self.baseSpeedX = speed
        self.category = cat
        self.minLoops = minL
        self.maxLoops = maxL
    }
}

@Model
class FoodMetadata {
    @Attribute(.unique) var foodId: Int
    var nameKey: String
    var filename: String
    var isVegetarian: Bool
    init(id: Int, name: String, file: String, isVeg: Bool) {
        self.foodId = id
        self.nameKey = name
        self.filename = file
        self.isVegetarian = isVeg
    }
}

@Model
class DietMetadata {
    var speciesId: Int
    var foodId: Int
    init(speciesId: Int, foodId: Int) {
        self.speciesId = speciesId
        self.foodId = foodId
    }
}

@Model
class PetModel {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var speciesId: Int
    var scale: Double = 1.0
    var personalityId: Int = 3
    var speedId: Int = 4
    var physicsMode: Int = 0
    var screenEdgeMode: Int = 1
    var isLaunched: Bool = false
    var hunger: Double = 100.0
    var hungerTime: Double = 50.0
    var hungerRate: Double = 0.2
    var lastUpdate: Date = Date()
    
    init(name: String, speciesId: Int) {
        self.name = name
        self.speciesId = speciesId
        self.id = UUID()
        self.isLaunched = false
        self.lastUpdate = Date()
    }
}
