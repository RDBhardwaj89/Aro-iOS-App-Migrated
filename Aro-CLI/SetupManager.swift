// 1. File name: SetupManager.swift
// 2. Version: 18.0
// 3. Date and time: Jan 8, 2026, 11:30 AM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Fixed relationship mutation errors. Seeds full metadata rules for all subfolders.

import Foundation
import SwiftData

@MainActor
class SetupManager {
    static func seed(context: ModelContext) {
        let descriptor = FetchDescriptor<SpeciesMetadata>()
        if (try? context.fetchCount(descriptor)) ?? 0 == 0 {
            
            // --- DOG SEED ---
            let dog = SpeciesMetadata(id: 1, name: "Dog", path: "Dog", start: "Walk", defName: "Inu", icon: "dog-exotic-jump/sprite_0005")
            context.insert(dog)
            
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Sleep", folder: "dog-exotic-sleeping", frames: 15, speed: PetConstants.Speed.stop, cat: 0, minL: 20, maxL: 50))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Sit", folder: "dog-exotic-sit", frames: 5, speed: PetConstants.Speed.stop, cat: 0, minL: 10, maxL: 20))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Laying", folder: "dog-exotic-laying", frames: 3, speed: PetConstants.Speed.stop, cat: 0, minL: 5, maxL: 10))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Sniff", folder: "dog-exotic-sniff", frames: 7, speed: PetConstants.Speed.crawl, cat: 1, minL: 2, maxL: 10))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Crouch", folder: "dog-exotic-crouch", frames: 7, speed: PetConstants.Speed.crawl, cat: 1, minL: 2, maxL: 10))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Walk", folder: "dog-exotic-walk", frames: 7, speed: PetConstants.Speed.walk, cat: 2, minL: 10, maxL: 25))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Run", folder: "dog-exotic-run", frames: 3, speed: PetConstants.Speed.jump, cat: 2, minL: 10, maxL: 30))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Jump", folder: "dog-exotic-jump", frames: 6, speed: PetConstants.Speed.jump, cat: 2, minL: 5, maxL: 10))

            // --- GOOSE SEED ---
            let goose = SpeciesMetadata(id: 2, name: "Goose", path: "Goose", start: "Walk", defName: "Miss Honk", icon: "goose1-fly/sprite_0002")
            context.insert(goose)
            
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Sleep", folder: "goose1-sleep", frames: 6, speed: PetConstants.Speed.stop, cat: 0, minL: 10, maxL: 20))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Idle", folder: "goose1-idle", frames: 21, speed: PetConstants.Speed.stop, cat: 0, minL: 5, maxL: 15))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Look", folder: "goose1-look", frames: 21, speed: PetConstants.Speed.stop, cat: 0, minL: 2, maxL: 5))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Eat", folder: "goose1-eat", frames: 8, speed: PetConstants.Speed.stop, cat: 0, minL: 5, maxL: 15))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Walk", folder: "goose1-walk", frames: 4, speed: PetConstants.Speed.walk, cat: 2, minL: 3, maxL: 8))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Fly", folder: "goose1-fly", frames: 4, speed: PetConstants.Speed.fly, cat: 2, minL: 20, maxL: 60))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Jump", folder: "goose1-jump", frames: 6, speed: PetConstants.Speed.fast, cat: 2, minL: 1, maxL: 1))
            
            try? context.save()
        }
    }
}
