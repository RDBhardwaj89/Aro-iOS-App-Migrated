// 1. File name: PetViewModel.swift
// 2. Version: 2.2
// 3. Date and time: Jan 5, 2026, 02:30 PM (IST)
// 4. Target for this file: Aro-CLI
// 5. Purpose of this file: Advanced movement with two-way wrap-around logic and fixed sprite orientation.

import Foundation
import SwiftUI
import Combine

class PetViewModel: ObservableObject {
    @Published var x: CGFloat = 150
    @Published var y: CGFloat = 300
    @Published var directionX: CGFloat = 1
    @Published var directionY: CGFloat = 1
    @Published var currentFrame: Int = 1
    
    @Published var scale: Double = 1.0
    @Published var speedId: Int = 4
    @Published var physicsMode: Int = 0
    @Published var screenEdgeMode: Int = 1
    
    var roomWidth: CGFloat = 350
    var roomHeight: CGFloat = 600
    private var timer: Timer?
    var petData: PetModel?
    
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.update()
        }
    }
    
    func syncWithDatabase(model: PetModel) {
        self.petData = model
        self.scale = model.scale
        self.speedId = model.speedId
        self.physicsMode = model.physicsMode
        self.screenEdgeMode = model.screenEdgeMode
    }
    
    func saveToDatabase() {
        guard let data = petData else { return }
        data.scale = self.scale
        data.speedId = self.speedId
        data.physicsMode = self.physicsMode
        data.screenEdgeMode = self.screenEdgeMode
    }

    func update() {
        let baseSpeed: CGFloat = CGFloat(speedId) * 1.5
        let vSpeed: CGFloat = 5.0
        
        // 1. VERTICAL MODES
        switch physicsMode {
        case 0: if y < (roomHeight - 120) { y += vSpeed } else { y = roomHeight - 120 }
        case 2: if y > 120 { y -= vSpeed } else { y = 120 }
        case 3: y += (vSpeed * directionY); if y > (roomHeight - 120) || y < 120 { directionY *= -1 }
        default: break
        }
        
        // 2. HORIZONTAL MOVEMENT
        x += (baseSpeed * directionX)

        if screenEdgeMode == 1 {
            // BOUNCE MODE
            if x > (roomWidth - 60) { directionX = -1 }
            else if x < 60 { directionX = 1 }
        } else {
            // WALK AROUND (WRAP) MODE
            if x > roomWidth + 80 {
                teleport(to: -80)
            } else if x < -80 {
                teleport(to: roomWidth + 80)
            }
        }
        
        currentFrame = (currentFrame % 7) + 1
    }
    
    private func teleport(to newX: CGFloat) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            self.x = newX
        }
    }
    
    func getSpritePath() -> String {
        let frameName = String(format: "sprite_%04d", currentFrame)
        return "PetAssets/Dog/dog-exotic-walk/\(frameName)"
    }
}
