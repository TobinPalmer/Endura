import ActivityKit
import SwiftUI
import WidgetKit

struct EnduraWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    /// Fixed non-changing properties about your activity go here!
    var name: String
}

// struct EnduraWidgetLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: EnduraWidgetAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint( Color("EnduraRed"))
//        }
//    }
// }

private extension EnduraWidgetAttributes {
    static var preview: EnduraWidgetAttributes {
        EnduraWidgetAttributes(name: "World")
    }
}

private extension EnduraWidgetAttributes.ContentState {
    static var smiley: EnduraWidgetAttributes.ContentState {
        EnduraWidgetAttributes.ContentState(emoji: "😀")
    }

    static var starEyes: EnduraWidgetAttributes.ContentState {
        EnduraWidgetAttributes.ContentState(emoji: "🤩")
    }
}

#Preview("Notification", as: .content, using: EnduraWidgetAttributes.preview) {} contentStates: {
    EnduraWidgetAttributes.ContentState.smiley
    EnduraWidgetAttributes.ContentState.starEyes
}
