// 1. File name: PetModel.swift
// 2. Version: 18.0
// 3. Date and time: Jan 8, 2026, 11:30 AM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Relational database schema with loop constants and metadata linkage.

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
        self.speciesId = id; self.name = name; self.basePath = path;
        self.startAnimation = start; self.defaultName = defName; self.iconPath = icon
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
        self.speciesId = speciesId; self.name = name; self.folderName = folder;
        self.frameCount = frames; self.baseSpeedX = speed; self.category = cat
        self.minLoops = minL; self.maxLoops = maxL
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
    
    init(name: String, speciesId: Int) {
        self.name = name; self.speciesId = speciesId; self.id = UUID(); self.isLaunched = false
    }
}
