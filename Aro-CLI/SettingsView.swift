// 1. File name: SettingsView.swift
// 2. Version: 18.0
// 3. Date and time: Jan 8, 2026, 11:30 AM (IST)
// 4. Target group: Aro-CLI
// 5. Purpose: Corrected tappable slider logic and live-refresh function.

import SwiftUI
import SwiftData

struct SettingsView: View {
    @ObservedObject var pet: PetViewModel
    var species: SpeciesMetadata?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var petName: String
    @State private var dScale: Double
    @State private var dPers: Int
    @State private var dSpeed: Int
    @State private var dPhys: Int
    @State private var dEdge: Int

    init(pet: PetViewModel, species: SpeciesMetadata?) {
        self.pet = pet; self.species = species
        _petName = State(initialValue: pet.model.name)
        _dScale = State(initialValue: pet.model.scale)
        _dPers = State(initialValue: pet.model.personalityId)
        _dSpeed = State(initialValue: pet.model.speedId)
        _dPhys = State(initialValue: pet.model.physicsMode)
        _dEdge = State(initialValue: pet.model.screenEdgeMode)
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                if let path = Bundle.main.path(forResource: "PetAssets/\(species?.basePath ?? "")/\(species?.iconPath ?? "")", ofType: "png"), let img = UIImage(contentsOfFile: path) {
                    Image(uiImage: img).resizable().scaledToFit().frame(width: 60)
                }
                HStack {
                    TextField("Name", text: $petName).font(.title3).bold().multilineTextAlignment(.center).textFieldStyle(.plain)
                    Image(systemName: "pencil").foregroundColor(.gray)
                }.frame(width: 200)
            }.padding(.top)

            VStack(alignment: .leading, spacing: 15) {
                Text("Behavior").font(.headline).foregroundColor(.gray)
                tappableRow(label: "Size", value: $dScale, range: 0.5...2.0, display: "\(String(format: "%.1f", dScale))x")
                tappableRow(label: "Personality", value: Binding(get: { Double(dPers) }, set: { dPers = Int($0) }), range: 1...5, display: ["", "Sleepy", "Calm", "Balanced", "Active", "Super Active"][dPers])
                tappableRow(label: "Speed", value: Binding(get: { Double(dSpeed) }, set: { dSpeed = Int($0) }), range: 1...7, display: ["", "Super Slow", "Slow", "Kinda Slow", "Normal", "Kinda Fast", "Fast", "Super Fast"][dSpeed])
            }
            .padding().background(Color.gray.opacity(0.05)).cornerRadius(20)

            VStack(alignment: .leading, spacing: 15) {
                Text("Placement").font(.headline).foregroundColor(.gray)
                HStack { Text("Vertical"); Spacer(); Picker("", selection: $dPhys) { Text("Floor").tag(0); Text("Free").tag(1); Text("Float").tag(2); Text("Bounce").tag(3) }.pickerStyle(.menu) }
                HStack { Text("Horizontal"); Spacer(); Picker("", selection: $dEdge) { Text("Wrap").tag(0); Text("Bounce").tag(1) }.pickerStyle(.menu) }
            }
            .padding().background(Color.gray.opacity(0.05)).cornerRadius(20)

            HStack {
                Button("Delete Pet") { modelContext.delete(pet.model); try? modelContext.save(); dismiss() }.frame(maxWidth: .infinity).padding().background(Color.red.opacity(0.1)).foregroundColor(.red).cornerRadius(15)
                Button("Save Changes") { save() }.frame(maxWidth: .infinity).padding().background(Color.black).foregroundColor(.white).cornerRadius(15)
            }
            Spacer()
        }.padding(30)
    }

    func tappableRow(label: String, value: Binding<Double>, range: ClosedRange<Double>, display: String) -> some View {
        VStack(spacing: 0) {
            HStack { Text(label); Spacer(); Text(display).bold() }.font(.subheadline)
            GeometryReader { geo in
                Slider(value: value, in: range).gesture(DragGesture(minimumDistance: 0).onEnded { val in
                    let percent = val.location.x / geo.size.width
                    value.wrappedValue = (range.lowerBound + (percent * (range.upperBound - range.lowerBound)))
                })
            }.frame(height: 30)
        }
    }

    func save() {
        pet.model.name = petName; pet.model.scale = dScale; pet.model.personalityId = dPers; pet.model.speedId = dSpeed; pet.model.physicsMode = dPhys; pet.model.screenEdgeMode = dEdge
        pet.refreshFromModel(); try? modelContext.save(); dismiss()
    }
}
