import Foundation
import SwiftUI
import UIKit

enum MedalColors {
    case gold
    case silver
    case platinum
    case bronze
    var colors: [Color] {
        switch self {
        case .gold: return [Color(hex: "DBB400"),
                            Color(hex: "EFAF00"),
                            Color(hex: "F5D100"),
                            Color(hex: "F5D100"),
                            Color(hex: "D1AE15"),
                            Color(hex: "DBB400")]

        case .silver: return [Color(hex: "70706F"),
                              Color(hex: "7D7D7A"),
                              Color(hex: "B3B6B5"),
                              Color(hex: "8E8D8D"),
                              Color(hex: "B3B6B5"),
                              Color(hex: "A1A2A3")]

        case .platinum: return [Color(hex: "000000"),
                                Color(hex: "444444"),
                                Color(hex: "000000"),
                                Color(hex: "444444"),
                                Color(hex: "111111"),
                                Color(hex: "000000")]

        case .bronze: return [Color(hex: "804A00"),
                              Color(hex: "9C7A3C"),
                              Color(hex: "B08D57"),
                              Color(hex: "895E1A"),
                              Color(hex: "804A00"),
                              Color(hex: "B08D57")]
        }
    }

    var linearGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct AchievementCard: View {
    private let time: Double
    private let title: String

    init(time: Double, title: String) {
        self.time = time
        self.title = title
    }

    var body: some View {
        ZStack {
            VStack {
                Text(FormattingUtils.secondsToFormattedTimeColon(time))
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        Color(UIColor.blend(color1: .white, intensity1: 0.7, color2: .yellow, intensity2: 0.3)).shadow(
                            .inner(color: .black.opacity(0.25), radius: 0, x: 0, y: 2)
                        )
                    )
                    .foregroundColor(.white)

                Text(title)
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        Color(UIColor.blend(color1: .white, intensity1: 0.7, color2: .yellow, intensity2: 0.3)).shadow(
                            .inner(color: .black.opacity(0.25), radius: 0, x: 0, y: 2)
                        )
                    )
                    .foregroundColor(.white)
            }
            .frame(width: 150, height: 150)
            .background(MedalColors.gold.linearGradient)
            .clipShape(Circle())
            Circle()
                // Gold outline
                .stroke(MedalColors.gold.colors[0], lineWidth: 4)
                .frame(width: 145, height: 145)
        }
        .padding(4)
    }
}

struct AddAchievementCard: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("TextMuted").opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10]))
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
