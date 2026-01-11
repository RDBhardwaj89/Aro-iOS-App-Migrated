// 1. File name: AroWidget.swift
// 2. Version: 62.0
// 3. Date and time: Jan 10, 2026, 01:15 PM (IST)
// 4. Target group: AroWidgetExtension
// 5. Purpose: Professional Home Widget UI reading a centralized JSON registry to display multiple pets.

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let sharedSuite = UserDefaults(suiteName: "group.com.BrainBliss.Aro-CLI")

    func placeholder(in context: Context) -> SimpleEntry {
        let p = WidgetPetStatus(id: UUID(), name: "Aro", hunger: 100.0, speciesId: 1, iconPath: "Dog/dog-exotic-walk/sprite_0001")
        return SimpleEntry(date: Date(), pets: [p])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var displayPets: [WidgetPetStatus] = []
        if let data = sharedSuite?.data(forKey: "activePetsList"),
           let decoded = try? JSONDecoder().decode([WidgetPetStatus].self, from: data) {
            displayPets = decoded.sorted(by: { $0.hunger < $1.hunger })
        }
        let entry = SimpleEntry(date: Date(), pets: Array(displayPets.prefix(2)))
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let pets: [WidgetPetStatus]
}

struct AroWidgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        HStack(spacing: 0) {
            if entry.pets.isEmpty {
                Text("No pets launched").font(.caption).foregroundColor(.gray)
            } else {
                ForEach(entry.pets, id: \.id) { pet in
                    PetStatusColumn(pet: pet)
                    if pet.id != entry.pets.last?.id {
                        Divider().padding(.vertical, 15).opacity(0.3)
                    }
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct PetStatusColumn: View {
    let pet: WidgetPetStatus
    var body: some View {
        VStack(spacing: 5) {
            if let path = Bundle.main.path(forResource: "PetAssets/\(pet.iconPath)", ofType: "png"),
               let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage).resizable().scaledToFit().frame(width: 45, height: 45)
            } else {
                Text(pet.speciesId == 1 ? "🐶" : "🦢").font(.title2)
            }
            Text(pet.name).font(.system(size: 11, weight: .bold))
            HStack(spacing: 8) {
                Circle().fill(pet.hunger < 50 ? Color.red : Color.red.opacity(0.1)).frame(width: 8, height: 8)
                Circle().fill(pet.hunger >= 50 && pet.hunger < 80 ? Color.orange : Color.orange.opacity(0.1)).frame(width: 8, height: 8)
                Circle().fill(pet.hunger >= 80 ? Color.green : Color.green.opacity(0.1)).frame(width: 8, height: 8)
            }
            .padding(6).background(Color.black.opacity(0.05)).cornerRadius(8)
            Text("\(Int(pet.hunger))%").font(.system(size: 9, weight: .bold)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AroWidget: Widget {
    let kind: String = "AroWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AroWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Aro Health")
        .description("Track your pet vitality.")
        .supportedFamilies([.systemMedium])
    }
}
