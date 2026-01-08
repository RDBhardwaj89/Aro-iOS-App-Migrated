// 1. File name: ContentView.swift
// 2. Version: 16.0
// 3. Date and time: Jan 8, 2026, 09:45 AM IST
// 4. Target group: Aro-CLI
// 5. Purpose: Main app stage. Long press background to return to the Manager.

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var savedInstances: [PetModel]
    @Query var masterSpecies: [SpeciesMetadata]
    @State private var activeBrains: [UUID: PetViewModel] = [:]
    @State private var isLaunched = false
    @State private var selectedPetVM: PetViewModel?

    var body: some View {
        GeometryReader { geo in
            if !isLaunched {
                ManagerView(isLaunched: $isLaunched, roomSize: geo.size)
            } else {
                ZStack {
                    Color.black.opacity(0.001).edgesIgnoringSafeArea(.all).contentShape(Rectangle())
                        .onLongPressGesture {
                            for pet in savedInstances { pet.isLaunched = false }
                            isLaunched = false
                        }
                    ForEach(savedInstances.filter { $0.isLaunched }) { instance in
                        if let brain = getBrain(for: instance, size: geo.size) {
                            let species = masterSpecies.first(where: { $0.speciesId == instance.speciesId })
                            PetSpriteView(pet: brain, species: species).onTapGesture { selectedPetVM = brain }
                        }
                    }
                }
            }
        }
        .onAppear {
            SetupManager.seed(context: modelContext)
            if savedInstances.contains(where: { $0.isLaunched }) { isLaunched = true }
        }
        .sheet(item: $selectedPetVM) { vm in
            let species = masterSpecies.first(where: { $0.speciesId == vm.model.speciesId })
            SettingsView(pet: vm, species: species)
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
        if let path = Bundle.main.path(forResource: pet.getSpritePath(species: species), ofType: "png"),
           let img = UIImage(contentsOfFile: path) {
            Image(uiImage: img).resizable().scaledToFit()
                .frame(width: 45 * pet.scale, height: 45 * pet.scale)
                .scaleEffect(x: pet.directionX, y: 1).position(x: pet.x, y: pet.y)
                .animation(pet.isDragging ? nil : .linear(duration: 0.1), value: pet.x)
                .gesture(DragGesture().onChanged { v in pet.isDragging = true; pet.x = v.location.x; pet.y = v.location.y }.onEnded { _ in pet.isDragging = false })
        } else {
            Text(pet.model.speciesId == 2 ? "🦢" : "🐶").font(.system(size: 40)).position(x: pet.x, y: pet.y)
        }
    }
}
