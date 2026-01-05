// 1. File name: SettingsView.swift
// 2. Version: 1.6
// 3. Date and time: Jan 5, 2026, 02:35 PM (IST)
// 4. Target for this file: Aro-CLI
// 5. Purpose of this file: Single-click settings with language toggle and segmented control.

import SwiftUI

struct SettingsView: View {
    @ObservedObject var pet: PetViewModel
    @StateObject var lang = LanguageManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var dScale: Double
    @State private var dSpeed: Int
    @State private var dPhysics: Int
    @State private var dEdge: Int
    
    init(pet: PetViewModel) {
        self.pet = pet
        _dScale = State(initialValue: pet.scale)
        _dSpeed = State(initialValue: pet.speedId)
        _dPhysics = State(initialValue: pet.physicsMode)
        _dEdge = State(initialValue: pet.screenEdgeMode)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // LANGUAGE SECTION
                Section(header: Text("Language / Sprache")) {
                    HStack {
                        Button("English") { lang.loadLanguage("en") }.buttonStyle(.bordered)
                        Button("Deutsch") { lang.loadLanguage("de") }.buttonStyle(.bordered)
                    }
                }

                // BEHAVIOR SECTION
                Section(header: Text(lang.get("Lbl_Behavior"))) {
                    VStack(alignment: .leading) {
                        Text("\(lang.get("Lbl_Size")): \(String(format: "%.1f", dScale))x")
                        Slider(value: $dScale, in: 0.5...3.0, step: 0.1)
                    }
                    VStack(alignment: .leading) {
                        Text("\(lang.get("Lbl_Speed")): \(lang.get("Val_Speed_\(dSpeed)"))")
                        Stepper("", value: $dSpeed, in: 1...7)
                    }
                }
                
                // PLACEMENT SECTION (Single-Click Segmented Buttons!)
                Section(header: Text(lang.get("Lbl_Placement"))) {
                    VStack(alignment: .leading) {
                        Text(lang.get("Lbl_Gravity"))
                        Picker("", selection: $dPhysics) {
                            Text("Floor").tag(0)
                            Text("Free").tag(1)
                            Text("Float").tag(2)
                            Text("Bounce").tag(3)
                        }.pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(lang.get("Lbl_Edge"))
                        Picker("", selection: $dEdge) {
                            Text("Wrap").tag(0)
                            Text("Bounce").tag(1)
                        }.pickerStyle(.segmented)
                    }
                }
            }
            .navigationTitle(lang.get("Title_Settings"))
            .toolbar {
                Button(lang.get("Btn_Save")) {
                    saveAndExit()
                }
            }
        }
    }
    
    func saveAndExit() {
        pet.scale = dScale
        pet.speedId = dSpeed
        pet.physicsMode = dPhysics
        pet.screenEdgeMode = dEdge
        pet.saveToDatabase()
        dismiss()
    }
}
