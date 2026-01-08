// 1. File name: ManagerView.swift
// 2. Version: 16.0
// 3. Date and time: Jan 8, 2026, 09:45 AM IST
// 4. Target group: Aro-CLI
// 5. Purpose: Windows-style Launcher with real asset thumbnails and multi-pet adding logic.

import SwiftUI
import SwiftData

struct ManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PetModel.name) var myPets: [PetModel]
    @Query var speciesList: [SpeciesMetadata]
    @Binding var isLaunched: Bool
    var roomSize: CGSize
    @State private var showingSelection = false
    @State private var selectedPetForEdit: PetModel?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("EN").font(.caption).bold().padding(8).background(Color.blue.opacity(0.1)).cornerRadius(5)
                Spacer(); Text("Aro").font(.title2).bold(); Spacer()
                Image(systemName: "line.3.horizontal").foregroundColor(.gray)
            }.padding()
            Divider()
            ScrollView {
                LazyVGrid(columns: [GridItem(.fixed(140)), GridItem(.fixed(140))], spacing: 20) {
                    ForEach(myPets) { pet in
                        let species = speciesList.first(where: { $0.speciesId == pet.speciesId })
                        petCard(pet: pet, species: species).onTapGesture { selectedPetForEdit = pet }
                    }
                    Button(action: { showingSelection = true }) {
                        RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.2), lineWidth: 2)
                            .frame(width: 130, height: 160).overlay(Image(systemName: "plus").font(.system(size: 40)).foregroundColor(.gray))
                    }
                }.padding(.top, 20)
            }
            Button(action: { for pet in myPets { pet.isLaunched = true }; isLaunched = true }) {
                Text("LAUNCH ALL ▶").font(.headline).foregroundColor(.white).frame(width: 250, height: 50).background(Color.black).cornerRadius(25)
            }.padding(.bottom, 20)
        }
        .sheet(isPresented: $showingSelection) { PetSelectionOverlay(speciesList: speciesList) }
        .sheet(item: $selectedPetForEdit) { pet in
            let species = speciesList.first(where: { $0.speciesId == pet.speciesId })
            SettingsView(pet: PetViewModel(model: pet, species: species), species: species)
        }
    }
    
    func petCard(pet: PetModel, species: SpeciesMetadata?) -> some View {
        VStack {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18).fill(Color.blue.opacity(0.05)).frame(width: 130, height: 160)
                Text("Aro").font(.system(size: 10)).bold().foregroundColor(.yellow).padding(10)
                if let species = species, let path = Bundle.main.path(forResource: "PetAssets/\(species.basePath)/\(species.iconPath)", ofType: "png"), let img = UIImage(contentsOfFile: path) {
                    Image(uiImage: img).resizable().scaledToFit().frame(width: 80).position(x: 65, y: 80)
                }
            }
            Text(pet.name).font(.caption).bold()
        }
    }
}

struct PetSelectionOverlay: View {
    var speciesList: [SpeciesMetadata]
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("Add New Pet").font(.title2).bold().padding()
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(speciesList) { species in
                        Button(action: {
                            let new = PetModel(name: species.name == "Dog" ? "Inu" : "Miss Honk", speciesId: species.speciesId)
                            context.insert(new); dismiss()
                        }) {
                            VStack {
                                if let path = Bundle.main.path(forResource: "PetAssets/\(species.basePath)/\(species.iconPath)", ofType: "png"), let img = UIImage(contentsOfFile: path) {
                                    Image(uiImage: img).resizable().scaledToFit().frame(width: 60)
                                }
                                Text(species.name).bold().foregroundColor(.primary)
                            }.frame(width: 120, height: 140).background(Color.blue.opacity(0.1)).cornerRadius(15)
                        }
                    }
                }.padding()
            }
            Spacer()
        }.presentationDetents([.medium])
    }
}
