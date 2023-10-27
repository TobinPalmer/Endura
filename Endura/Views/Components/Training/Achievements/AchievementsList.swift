import Foundation
import SwiftUI

struct AchievementsList: View {
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 16), count: 2), spacing: 16) {
                AchievementCard(time: 360, title: "1 Mile")
                AchievementCard(time: 1080, title: "5k Run")
                AchievementCard(time: 2240, title: "10k Run")
                AddAchievementCard()
            }
        }
    }
}
