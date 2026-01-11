// 1. File name: PetViewModel.swift
// 2. Version: 62.0
// 3. Date and time: Jan 10, 2026, 01:15 PM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Master logic engine with centralized WidgetSyncManager to prevent multi-pet data overwriting.

import Foundation
import SwiftUI
import Combine
import SwiftData
import WidgetKit

class WidgetSyncManager {
    static let shared = WidgetSyncManager()
    private let sharedSuite = UserDefaults(suiteName: PetConstants.appGroup)
    private var petRegistry: [UUID: WidgetPetStatus] = [:]

    func updatePetStatus(id: UUID, name: String, hunger: Double, speciesId: Int) {
        let path = (speciesId == 1) ? "Dog/dog-exotic-walk/sprite_0001" : "Goose/goose1-walk/sprite_0001"
        let status = WidgetPetStatus(id: id, name: name, hunger: hunger, speciesId: speciesId, iconPath: path)
        
        petRegistry[id] = status
        broadcastToWidget()
    }

    private func broadcastToWidget() {
        let allPets = Array(petRegistry.values)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(allPets) {
            sharedSuite?.set(encoded, forKey: PetConstants.suiteKey)
            sharedSuite?.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

class PetViewModel: ObservableObject, Identifiable {
    let id: UUID
    var model: PetModel
    var speciesRules: SpeciesMetadata?
    
    @Published var x: CGFloat = CGFloat.random(in: 50...300)
    @Published var y: CGFloat = CGFloat.random(in: 100...500)
    @Published var directionX: CGFloat = 1
    @Published var directionY: CGFloat = 1
    @Published var currentFrame: Int = 1
    @Published var currentAnim: AnimationMetadata?
    @Published var currentAnimName: String = "Walk"
    @Published var isDragging: Bool = false
    @Published var isEating: Bool = false
    @Published var isChasing: Bool = false
    @Published var hungerEmojiOpacity: Double = 0.0

    @Published var scale: Double = 1.0
    @Published var hunger: Double = 100.0
    @Published var speedId: Int = 4
    @Published var personalityId: Int = 3
    @Published var physicsMode: Int = 0
    @Published var screenEdgeMode: Int = 1
    
    var roomWidth: CGFloat = 350
    var roomHeight: CGFloat = 600
    private var loopsRemaining: Int = 10
    private var timer: Timer?

    init(model: PetModel, species: SpeciesMetadata?) {
        self.id = model.id
        self.model = model
        self.speciesRules = species
        refreshFromModel()
        setupAnimation(species?.startAnimation ?? "Walk")
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    var vitalityMultiplier: Double {
        if hunger < 50 { return 0.4 }
        else if hunger < 80 { return 0.8 }
        else { return 1.0 }
    }

    var moodColor: Color {
        if hunger < 50 { return .red }
        else if hunger < 80 { return .orange }
        else { return .green.opacity(0.6) }
    }

    var petOpacity: Double {
        return 0.5 + (hunger / 100.0 * 0.5)
    }

    func update() {
        guard !isDragging && !isEating else { return }
        
        let totalTicks = max(1.0, model.hungerTime) * 600.0
        hunger = max(0, hunger - (100.0 / totalTicks))
        
        // Report to the Central Tower every 1% drop
        if Int(hunger * 100) % 100 == 0 {
            WidgetSyncManager.shared.updatePetStatus(id: self.id, name: model.name, hunger: self.hunger, speciesId: model.speciesId)
        }

        if !isChasing {
            let speeds: [Double] = [0, 0.2, 0.5, 0.8, 1.0, 1.5, 2.0, 3.0]
            let moveSpeed = (currentAnim?.baseSpeedX ?? 3.0) * speeds[speedId] * vitalityMultiplier
            x += (moveSpeed * directionX)
            
            let halfW = (45 * scale) / 2
            if x > (roomWidth - halfW) { directionX = -1; x -= 2 }
            if x < halfW { directionX = 1; x += 2 }
        }

        currentFrame += 1
        if currentFrame > (currentAnim?.frameCount ?? 1) {
            currentFrame = 1
            if !isChasing { loopsRemaining -= 1; if loopsRemaining <= 0 { decideNextMood() } }
        }
    }

    func wakeUpAndChase(targetX: CGFloat, targetY: CGFloat) {
        let dx = targetX - x
        let dy = targetY - y
        let dist = sqrt(dx*dx + dy*dy)
        if currentAnimName == "Sleep" {
            if dist < 250 { setupAnimation("Walk") }
            return
        }
        isChasing = true
        if dist > 200 {
            if currentAnimName != "Run" && currentAnimName != "Fly" { setupAnimation(model.speciesId == 2 ? "Fly" : "Run") }
        } else {
            if currentAnimName != "Walk" { setupAnimation("Walk") }
        }
        let speeds: [Double] = [0, 0.2, 0.5, 0.8, 1.0, 1.5, 2.0, 3.0]
        let speed = (dist > 200 ? 10.0 : 5.0) * speeds[speedId] * vitalityMultiplier
        moveTowards(targetX: targetX, targetY: targetY, speed: speed)
    }

    func moveTowards(targetX: CGFloat, targetY: CGFloat, speed: CGFloat) {
        let dx = targetX - x
        let dy = targetY - y
        let dist = sqrt(dx*dx + dy*dy)
        if abs(dx) < 10 && abs(dy) > 10 {
            self.x = targetX
            self.y += (dy > 0 ? 1 : -1) * speed
        } else {
            if dist > 0 { self.x += (dx / dist) * speed; self.y += (dy / dist) * speed }
            if abs(dx) > 5 { self.directionX = dx > 0 ? 1 : -1 }
        }
    }

    func setupAnimation(_ name: String) {
        let anim = speciesRules?.animations.first(where: { $0.name == name }) ?? speciesRules?.animations.first
        self.currentAnim = anim
        self.currentAnimName = name
        self.currentFrame = 1
        self.loopsRemaining = Int.random(in: 10...30)
    }

    func decideNextMood() {
        let weights = (personalityId == 1) ? [80, 15, 5] : (personalityId == 5 ? [5, 15, 80] : [33, 33, 34])
        let roll = Int.random(in: 0...100)
        let targetCat = roll < weights[0] ? 0 : (roll < weights[0] + weights[1] ? 1 : 2)
        if targetCat == 0 { setupAnimation("Sleep") }
        else if targetCat == 1 { setupAnimation("Sit") }
        else { setupAnimation("Walk") }
    }

    func getSpritePath(species: SpeciesMetadata?) -> String {
        let framesStr = String(format: "sprite_%04d", currentFrame)
        let animFolder = currentAnim?.folderName ?? "dog-exotic-walk"
        return "PetAssets/\(species?.basePath ?? "Dog")/\(animFolder)/\(framesStr)"
    }
    
    func saveToDatabase() {
        model.scale = scale
        model.speedId = speedId
        model.personalityId = personalityId
        model.physicsMode = physicsMode
        model.screenEdgeMode = screenEdgeMode
        model.hunger = hunger
        try? model.modelContext?.save()
        WidgetSyncManager.shared.updatePetStatus(id: self.id, name: model.name, hunger: self.hunger, speciesId: model.speciesId)
    }

    func refreshFromModel() {
        self.scale = model.scale
        self.hunger = model.hunger
        self.speedId = model.speedId
        self.personalityId = model.personalityId
        self.physicsMode = model.physicsMode
        self.screenEdgeMode = model.screenEdgeMode
    }
    
    func eatFood(completion: @escaping () -> Void) {
        isEating = true; isChasing = false; setupAnimation(model.speciesId == 2 ? "Eat" : "Sit")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hunger = min(100, self.hunger + 35); self.isEating = false; self.setupAnimation("Walk"); self.saveToDatabase(); completion()
        }
    }
    func stopChase() { if isChasing { isChasing = false; setupAnimation("Walk") } }
    func teleport(to newX: CGFloat) { var trans = Transaction(); trans.disablesAnimations = true; withTransaction(trans) { self.x = newX } }
}
