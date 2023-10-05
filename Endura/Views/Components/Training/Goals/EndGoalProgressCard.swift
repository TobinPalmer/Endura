import Foundation
import SwiftUI

struct EndGoalProgressCard: View {
    @EnvironmentObject private var activeUser: ActiveUserModel

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                let progressRingSize = 100
                ZStack {
                    Circle()
                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 8)
                        .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
                        .rotationEffect(.degrees(-90))
                    VStack {
                        Text("20")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                        Text("days left")
                            .font(.caption)
                            .fontColor(.secondary)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("5 miles")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontColor(.primary)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Current")
                                .font(.caption)
                                .fontColor(.muted)
                            Text("22:30")
                                .fontWeight(.bold)
                                .fontColor(.secondary)
                        }
                        VStack(alignment: .leading) {
                            Text("Goal")
                                .font(.caption)
                                .fontColor(.muted)
                            Text("21:45")
                                .fontWeight(.bold)
                                .fontColor(.secondary)
                        }
                        .padding(.leading, 6)
                    }
                    .padding(.leading, 6)
                    Spacer()
                }
                .padding()
            }
        }
        .frame(height: 150)
    }
}
