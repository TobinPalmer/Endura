import Foundation
import SwiftUI

struct AchievementsList: View {
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 16), count: 2), spacing: 16) {
                AchievementCard()
                AchievementCard()
                AchievementCard()
                AddAchievementCard()
            }
        }
    }
}
