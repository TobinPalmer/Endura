import Foundation
import SwiftUI

struct AchievementCard: View {
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color(hex: "FFBF03").opacity(0.5))
            Circle()
                .strokeBorder(Color(hex: "FFBF03"), lineWidth: 6)
            VStack(spacing: 6) {
                Text("19:16")
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontColor(.primary)
                Text("5k Run")
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontColor(.secondary)
            }
            .padding(16)
        }
        .padding(4)
    }
}

struct AddAchievementCard: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("TextMuted"), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10]))
            VStack {
                Image(systemName: "plus")
                    .font(.title)
                    .fontWeight(.bold)
                    .fontColor(.muted)
                VStack {
                    Text("Add")
                    Text("Achievement")
                }
                .font(.system(size: 13))
                .fontWeight(.bold)
                .fontColor(.muted)
                .padding(.top, 6)
            }
        }
        .padding(4)
    }
}
