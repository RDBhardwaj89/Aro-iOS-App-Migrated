// 1. File name: PetViewModel.swift
// 2. Version: 18.0
// 3. Date and time: Jan 8, 2026, 11:30 AM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: 100% data-driven asset pathing using metadata folder names. Implements C# loop logic.

import Foundation
import SwiftUI
import Combine

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
    @Published var isDragging: Bool = false
    
    @Published var scale: Double = 1.0
    @Published var speedId: Int = 4
    @Published var personalityId: Int = 3
    @Published var physicsMode: Int = 0
    @Published var screenEdgeMode: Int = 1
    
    private var loopsRemaining: Int = 10
    var roomWidth: CGFloat = 350
    var roomHeight: CGFloat = 600
    private var timer: Timer?

    init(model: PetModel, species: SpeciesMetadata?) {
        self.id = model.id; self.model = model; self.speciesRules = species
        refreshFromModel()
        setupAnimation(species?.startAnimation ?? "Walk")
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in self?.update() }
    }

    func refreshFromModel() {
        self.scale = model.scale; self.speedId = model.speedId
        self.personalityId = model.personalityId; self.physicsMode = model.physicsMode
        self.screenEdgeMode = model.screenEdgeMode
    }

    func update() {
        guard !isDragging else { return }
        let speeds: [Double] = [0, 0.2, 0.5, 0.8, 1.0, 1.5, 2.0, 3.0]
        let currentSpeed = (currentAnim?.baseSpeedX ?? 3.0) * speeds[speedId]
        
        x += (currentSpeed * directionX)
        
        // Vertical Physics
        let vSpeed: CGFloat = 5.0 * speeds[speedId]
        switch physicsMode {
        case 0: if y < (roomHeight - 80) { y += vSpeed * 1.2 } else { y = roomHeight - 80 }
        case 2: if y > 80 { y -= vSpeed } else { y = 80 }
        case 3: y += (vSpeed * directionY); if y > (roomHeight - 80) || y < 80 { directionY *= -1 }
        default: break
        }

        // Edges
        if screenEdgeMode == 1 {
            if x > (roomWidth - 40) || x < 40 { directionX *= -1 }
        } else {
            if x > roomWidth + 80 { teleport(to: -80) }
            else if x < -80 { teleport(to: roomWidth + 80) }
        }
        
        // Animation Loop Logic
        currentFrame += 1
        if currentFrame > (currentAnim?.frameCount ?? 1) {
            currentFrame = 1
            loopsRemaining -= 1
            if loopsRemaining <= 0 { decideNextMood() }
        }
    }

    func setupAnimation(_ name: String) {
        let anim = speciesRules?.animations.first(where: { $0.name == name }) ?? speciesRules?.animations.first
        self.currentAnim = anim
        self.loopsRemaining = Int.random(in: (anim?.minLoops ?? 5)...(anim?.maxLoops ?? 15))
        self.currentFrame = 1
    }

    func decideNextMood() {
        let weights = (personalityId == 1) ? [80, 15, 5] : (personalityId == 5 ? [5, 15, 80] : [33, 33, 34])
        let roll = Int.random(in: 0...100)
        let targetCat = roll < weights[0] ? 0 : (roll < weights[0] + weights[1] ? 1 : 2)
        
        let choices = speciesRules?.animations.filter { $0.category == targetCat }
        if let newAnim = choices?.randomElement() { setupAnimation(newAnim.name) }
    }

    func getSpritePath(species: SpeciesMetadata?) -> String {
        let framesStr = String(format: "sprite_%04d", currentFrame)
        let speciesFolder = species?.basePath ?? "Dog"
        
        // 🛠 THE FINAL FIX: We use the folderName from Metadata exactly.
        // This makes sure Goose uses "goose1-idle" and Dog uses "dog-exotic-sleeping"
        // with no string manipulation errors.
        let animFolder = currentAnim?.folderName ?? "dog-exotic-walk"
        
        return "PetAssets/\(speciesFolder)/\(animFolder)/\(framesStr)"
    }

    func teleport(to newX: CGFloat) {
        var trans = Transaction(); trans.disablesAnimations = true
        withTransaction(trans) { self.x = newX }
    }
}
