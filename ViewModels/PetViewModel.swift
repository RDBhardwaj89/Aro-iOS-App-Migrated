// 1. File name: PetViewModel.swift
// 2. Version: 45.0
// 3. Date and time: Jan 9, 2026, 12:45 PM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: High-parity movement engine with wake-up logic, loop control, and petOpacity sync.

import Foundation
import SwiftUI
import Combine
import SwiftData

class PetViewModel: ObservableObject, Identifiable {
    let id: UUID
    var model: PetModel
    var speciesRules: SpeciesMetadata?
    @Published var x: CGFloat = CGFloat.random(in: 100...250)
    @Published var y: CGFloat = CGFloat.random(in: 200...400)
    @Published var directionX: CGFloat = 1
    @Published var directionY: CGFloat = 1
    @Published var currentFrame: Int = 1
    @Published var currentAnimName: String = "Walk"
    @Published var isDragging: Bool = false
    @Published var isEating: Bool = false
    @Published var isChasing: Bool = false
    @Published var hunger: Double = 100.0
    @Published var scale: Double = 1.0

    private var currentAnim: AnimationMetadata?
    private var loopsRemaining: Int = 10
    private var timer: Timer?
    var roomWidth: CGFloat = 350
    var roomHeight: CGFloat = 600

    init(model: PetModel, species: SpeciesMetadata?) {
        self.id = model.id; self.model = model; self.speciesRules = species
        self.scale = model.scale; self.hunger = model.hunger
        setupAnimation(species?.startAnimation ?? "Walk")
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in self?.update() }
    }

    func update() {
        guard !isDragging && !isEating else { return }
        let totalTicks = max(1.0, model.hungerTime) * 600.0
        hunger = max(0, hunger - (100.0 / totalTicks))
        if !isChasing {
            let speeds: [Double] = [0, 0.2, 0.5, 0.8, 1.0, 1.5, 2.0, 3.0]
            x += ((currentAnim?.baseSpeedX ?? 3.0) * speeds[model.speedId] * directionX)
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
        let dx = targetX - x; let dy = targetY - y; let dist = sqrt(dx*dx + dy*dy)
        if currentAnimName == "Sleep" { if dist < 250 { setupAnimation("Walk") }; return }
        isChasing = true
        if dist > 200 { if currentAnimName != "Run" && currentAnimName != "Fly" { setupAnimation(model.speciesId == 2 ? "Fly" : "Run") } }
        else { if currentAnimName != "Walk" { setupAnimation("Walk") } }
        let speeds: [Double] = [0, 0.2, 0.5, 0.8, 1.0, 1.5, 2.0, 3.0]
        moveTowards(targetX: targetX, targetY: targetY, speed: (dist > 200 ? 10.0 : 5.0) * speeds[model.speedId])
    }

    func moveTowards(targetX: CGFloat, targetY: CGFloat, speed: CGFloat) {
        let dx = targetX - x; let dy = targetY - y; let dist = sqrt(dx*dx + dy*dy)
        if abs(dx) < 10 && abs(dy) > 10 { self.x = targetX; self.y += (dy > 0 ? 1 : -1) * speed }
        else { if dist > 0 { self.x += (dx / dist) * speed; self.y += (dy / dist) * speed }; if abs(dx) > 5 { self.directionX = dx > 0 ? 1 : -1 } }
    }

    func setupAnimation(_ name: String) {
        let anim = speciesRules?.animations.first(where: { $0.name == name }) ?? speciesRules?.animations.first
        self.currentAnim = anim; self.currentAnimName = name; self.currentFrame = 1
        self.loopsRemaining = Int.random(in: (anim?.minLoops ?? 10)...(anim?.maxLoops ?? 20))
    }

    func decideNextMood() {
        let weights = (model.personalityId == 1) ? [80, 15, 5] : (model.personalityId == 5 ? [5, 15, 80] : [33, 33, 34])
        let roll = Int.random(in: 0...100); let targetCat = roll < weights[0] ? 0 : (roll < weights[0] + weights[1] ? 1 : 2)
        if targetCat == 0 { setupAnimation("Sleep") } else if targetCat == 1 { setupAnimation("Sit") } else { setupAnimation("Walk") }
    }

    func eatFood(completion: @escaping () -> Void) {
        isEating = true; isChasing = false; setupAnimation(model.speciesId == 2 ? "Eat" : "Sit")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hunger = min(100, self.hunger + 35); self.isEating = false; self.setupAnimation("Walk"); self.saveToDatabase(); completion()
        }
    }

    func getSpritePath(species: SpeciesMetadata?) -> String { "PetAssets/\(species?.basePath ?? "Dog")/\(currentAnim?.folderName ?? "dog-exotic-walk")/\(String(format: "sprite_%04d", currentFrame))" }
    func saveToDatabase() { model.hunger = self.hunger; try? model.modelContext?.save() }
    func refreshFromModel() { self.scale = model.scale; self.hunger = model.hunger }
    func stopChase() { if isChasing { isChasing = false; setupAnimation("Walk") } }
    func teleport(to newX: CGFloat) { var trans = Transaction(); trans.disablesAnimations = true; withTransaction(trans) { self.x = newX } }
    
    // 🛠 THE FIX: Property was missing in Version 44.0
    var petOpacity: Double { 0.5 + (hunger / 100.0 * 0.5) }
}
