// 1. File name: ContentView.swift
// 2. Version: 1.6
// 3. Date and time: Jan 5, 2026, 02:40 PM (IST)
// 4. Target for this file: Aro-CLI
// 5. Purpose of this file: Main stage for the pet with fixed animation transitions.

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var pet = PetViewModel()
    @StateObject var lang = LanguageManager.shared
    @Query var savedPets: [PetModel]
    @State private var showingSettings = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.blue.opacity(0.1).edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Text(lang.get("Menu_Pet")).font(.largeTitle).bold()
                        Spacer()
                        Button(action: { showingSettings.toggle() }) {
                            Image(systemName: "gearshape.fill").font(.title).foregroundColor(.gray)
                        }
                    }.padding(.top, 60).padding(.horizontal, 20)
                    Spacer()
                }

                if let imagePath = Bundle.main.path(forResource: pet.getSpritePath(), ofType: "png"),
                   let uiImage = UIImage(contentsOfFile: imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 100 * pet.scale, height: 100 * pet.scale)
                        .scaleEffect(x: pet.directionX, y: 1)
                        .position(x: pet.x, y: pet.y)
                        // This prevents the "Moonwalk/Fast Slide" during teleportation
                        .animation(abs(pet.x) > (pet.roomWidth - 20) ? nil : .linear(duration: 0.1), value: pet.x)
                        .gesture(DragGesture().onChanged { v in pet.x = v.location.x; pet.y = v.location.y })
                }
            }
            .onAppear {
                pet.roomWidth = geo.size.width
                pet.roomHeight = geo.size.height
                lang.loadLanguage("en")
                
                if let existing = savedPets.first {
                    pet.syncWithDatabase(model: existing)
                } else {
                    let newPet = PetModel()
                    modelContext.insert(newPet)
                    pet.syncWithDatabase(model: newPet)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(pet: pet)
            }
        }
    }
}
