// 1. File name: SetupManager.swift
// 2. Version: 49.0
// 3. Date and time: Jan 9, 2026, 05:30 PM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Master Data Seeder - Seeds all 15 animation folders using named constants. Cleaned logic to prevent mutation errors.

import Foundation
import SwiftData

@MainActor
class SetupManager {
    static func seed(context: ModelContext) {
        if (try? context.fetchCount(FetchDescriptor<SpeciesMetadata>())) == 0 {
            // --- DOG SEED (8 Folders) ---
            let dog = SpeciesMetadata(id: 1, name: "Dog", path: "Dog", start: "Walk", defName: "Inu", icon: "dog-exotic-jump/sprite_0005")
            context.insert(dog)
            
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Sleep", folder: "dog-exotic-sleeping", frames: 15, speed: PetConstants.Speed.stop, cat: PetConstants.Category.inactive, minL: 20, maxL: 50))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Sit", folder: "dog-exotic-sit", frames: 5, speed: PetConstants.Speed.stop, cat: PetConstants.Category.inactive, minL: 10, maxL: 20))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Laying", folder: "dog-exotic-laying", frames: 3, speed: PetConstants.Speed.stop, cat: PetConstants.Category.inactive, minL: 5, maxL: 10))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Sniff", folder: "dog-exotic-sniff", frames: 7, speed: PetConstants.Speed.crawl, cat: PetConstants.Category.neutral, minL: 2, maxL: 10))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Crouch", folder: "dog-exotic-crouch", frames: 7, speed: PetConstants.Speed.crawl, cat: PetConstants.Category.neutral, minL: 2, maxL: 10))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Walk", folder: "dog-exotic-walk", frames: 7, speed: PetConstants.Speed.walk, cat: PetConstants.Category.active, minL: 10, maxL: 25))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Run", folder: "dog-exotic-run", frames: 3, speed: PetConstants.Speed.fast, cat: PetConstants.Category.active, minL: 10, maxL: 30))
            dog.animations.append(AnimationMetadata(speciesId: 1, name: "Jump", folder: "dog-exotic-jump", frames: 6, speed: PetConstants.Speed.fast, cat: PetConstants.Category.active, minL: 5, maxL: 10))

            // --- GOOSE SEED (7 Folders) ---
            let goose = SpeciesMetadata(id: 2, name: "Goose", path: "Goose", start: "Walk", defName: "Miss Honk", icon: "goose1-fly/sprite_0001")
            context.insert(goose)
            
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Sleep", folder: "goose1-sleep", frames: 6, speed: PetConstants.Speed.stop, cat: PetConstants.Category.inactive, minL: 10, maxL: 20))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Idle", folder: "goose1-idle", frames: 21, speed: PetConstants.Speed.stop, cat: PetConstants.Category.inactive, minL: 5, maxL: 15))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Look", folder: "goose1-look", frames: 21, speed: PetConstants.Speed.stop, cat: PetConstants.Category.inactive, minL: 2, maxL: 5))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Eat", folder: "goose1-eat", frames: 8, speed: PetConstants.Speed.stop, cat: PetConstants.Category.inactive, minL: 5, maxL: 15))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Walk", folder: "goose1-walk", frames: 4, speed: PetConstants.Speed.walk, cat: PetConstants.Category.active, minL: 3, maxL: 8))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Fly", folder: "goose1-fly", frames: 4, speed: PetConstants.Speed.fly, cat: PetConstants.Category.active, minL: 20, maxL: 60))
            goose.animations.append(AnimationMetadata(speciesId: 2, name: "Jump", folder: "goose1-jump", frames: 6, speed: PetConstants.Speed.fast, cat: PetConstants.Category.active, minL: 1, maxL: 1))
        }

        if (try? context.fetchCount(FetchDescriptor<FoodMetadata>())) == 0 {
            let foods = [
                FoodMetadata(id: 1, name: "Burger", file: "Food/burger.png", isVeg: false),
                FoodMetadata(id: 2, name: "Apple", file: "Food/apple.png", isVeg: true),
                FoodMetadata(id: 3, name: "Meat", file: "Food/meat.png", isVeg: false),
                FoodMetadata(id: 4, name: "Bone", file: "Food/bone.png", isVeg: false),
                FoodMetadata(id: 5, name: "Fish", file: "Food/fish.png", isVeg: false),
                FoodMetadata(id: 6, name: "Eggs", file: "Food/egg.png", isVeg: false),
                FoodMetadata(id: 7, name: "Berries", file: "Food/berries.png", isVeg: true),
                FoodMetadata(id: 8, name: "Grass", file: "Food/grass.png", isVeg: true),
                FoodMetadata(id: 9, name: "Water", file: "Food/water.png", isVeg: true)
            ]
            for item in foods {
                context.insert(item)
            }
            
            let diets = [(1,1), (1,3), (1,4), (1,6), (1,9), (2,2), (2,5), (2,7), (2,8), (2,9), (2,1)]
            for pair in diets {
                context.insert(DietMetadata(speciesId: pair.0, foodId: pair.1))
            }
        }
        try? context.save()
    }
}
