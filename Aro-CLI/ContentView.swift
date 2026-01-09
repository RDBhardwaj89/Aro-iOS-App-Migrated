// 1. File name: ContentView.swift
// 2. Version: 45.0
// 3. Date and time: Jan 9, 2026, 12:45 PM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Playground with fixed opacity binding and integrated sprite renderer.

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var savedInstances: [PetModel]
    @Query var masterSpecies: [SpeciesMetadata]
    @Query var diets: [DietMetadata]
    @State private var activeBrains: [UUID: PetViewModel] = [:]
    @State private var activeFood: [FoodInstance] = []
    @State private var showingManager = true
    @State private var selectedPetVM: PetViewModel?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.blue.opacity(0.05).edgesIgnoringSafeArea(.all)
                ForEach($activeFood) { $food in
                    if let path = Bundle.main.path(forResource: "PetAssets/\(food.filename)", ofType: nil), let img = UIImage(contentsOfFile: path) {
                        Image(uiImage: img).resizable().scaledToFit().frame(width: 40, height: 40).position(x: food.x, y: food.y)
                            .gesture(DragGesture().onChanged { v in food.x = v.location.x; food.y = v.location.y })
                    }
                }
                ForEach(savedInstances) { instance in
                    if let brain = getBrain(for: instance, size: geo.size) {
                        let species = masterSpecies.first(where: { $0.speciesId == instance.speciesId })
                        PetSpriteView(pet: brain, species: species).onTapGesture { selectedPetVM = brain }.onAppear { startChaseLoop(brain) }
                    }
                }
                VStack { Spacer(); Capsule().fill(Color.gray.opacity(0.2)).frame(width: 40, height: 6).padding().onTapGesture { showingManager = true } }
            }
            .onAppear { SetupManager.seed(context: modelContext) }
            .sheet(isPresented: $showingManager) { ManagerView(activeFood: $activeFood, roomSize: geo.size) }
            .sheet(item: $selectedPetVM) { vm in
                let species = masterSpecies.first(where: { $0.speciesId == vm.model.speciesId })
                SettingsView(pet: vm, species: species)
            }
        }
    }

    func startChaseLoop(_ brain: PetViewModel) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard !brain.isEating && !brain.isDragging else { return }
            let myDiet = diets.filter { $0.speciesId == brain.model.speciesId }.map { $0.foodId }
            let validFood = activeFood.filter { myDiet.contains($0.foodId) && !$0.isClaimed }
            if let closest = validFood.min(by: { abs($0.x - brain.x) < abs($1.x - brain.x) }) {
                brain.wakeUpAndChase(targetX: closest.x, targetY: closest.y)
                if abs(closest.x - brain.x) < 30 && abs(closest.y - brain.y) < 30 {
                    if let idx = activeFood.firstIndex(where: { $0.id == closest.id }) {
                        activeFood[idx].isClaimed = true; brain.eatFood { activeFood.removeAll(where: { $0.id == closest.id }) }
                    }
                }
            } else { brain.stopChase() }
        }
    }
    
    func getBrain(for instance: PetModel, size: CGSize) -> PetViewModel? {
        if let existing = activeBrains[instance.id] { return existing }
        let species = masterSpecies.first(where: { $0.speciesId == instance.speciesId })
        let newBrain = PetViewModel(model: instance, species: species)
        newBrain.roomWidth = size.width; newBrain.roomHeight = size.height
        DispatchQueue.main.async { self.activeBrains[instance.id] = newBrain }
        return newBrain
    }
}

struct PetSpriteView: View {
    @ObservedObject var pet: PetViewModel
    var species: SpeciesMetadata?
    var body: some View {
        ZStack(alignment: .top) {
            ProgressView(value: pet.hunger, total: 100).progressViewStyle(.linear).frame(width: 40).tint(pet.hunger < 20 ? .red : .green).offset(y: -50)
            if let path = Bundle.main.path(forResource: pet.getSpritePath(species: species), ofType: "png"), let img = UIImage(contentsOfFile: path) {
                Image(uiImage: img).resizable().scaledToFit()
                    .frame(width: 45 * pet.scale, height: 45 * pet.scale)
                    .scaleEffect(x: pet.directionX, y: 1)
                    .opacity(pet.petOpacity) // 🛠 FIXED: No '$' here
                    .position(x: pet.x, y: pet.y)
                    .animation(pet.isDragging ? nil : .linear(duration: 0.1), value: pet.x)
                    .gesture(DragGesture().onChanged { v in pet.isDragging = true; pet.x = v.location.x; pet.y = v.location.y }.onEnded { _ in pet.isDragging = false })
            }
        }
    }
}
