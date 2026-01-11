// 1. File name: AroWidgetBundle.swift
// 2. Version: 1.0
// 3. Date and time: Jan 10, 2026, 12:15 PM (IST)
// 4. Target group: AroWidgetExtension
// 5. Purpose: Master entry point for all Aro widgets and Live Activities.

import WidgetKit
import SwiftUI

@main
struct AroWidgetBundle: WidgetBundle {
    var body: some Widget {
        AroWidget() // This points to your Traffic Light widget
        //AroWidgetLiveActivity() // This points to your future Dynamic Island
    }
}
