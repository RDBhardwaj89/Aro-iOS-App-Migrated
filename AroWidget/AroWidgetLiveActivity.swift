//
//  AroWidgetLiveActivity.swift
//  AroWidget
//
//  Created by RD Bhardwaj on 09/01/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AroWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AroWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AroWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension AroWidgetAttributes {
    fileprivate static var preview: AroWidgetAttributes {
        AroWidgetAttributes(name: "World")
    }
}

extension AroWidgetAttributes.ContentState {
    fileprivate static var smiley: AroWidgetAttributes.ContentState {
        AroWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AroWidgetAttributes.ContentState {
         AroWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AroWidgetAttributes.preview) {
   AroWidgetLiveActivity()
} contentStates: {
    AroWidgetAttributes.ContentState.smiley
    AroWidgetAttributes.ContentState.starEyes
}
