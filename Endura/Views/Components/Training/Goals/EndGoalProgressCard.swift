import Foundation
import SwiftUI

struct EndGoalProgressCard: View {
    @EnvironmentObject private var activeUser: ActiveUserModel

    var body: some View {
        VStack {
            if let endTrainingGoal = activeUser.training.endTrainingGoal {
                HStack(spacing: 10) {
                    let progressRingSize = 100
                    if endTrainingGoal.completed {
                        ZStack {
                            Circle()
                                .stroke(Color.accentColor.opacity(0.2), lineWidth: 8)
                                .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
                            Circle()
                                .trim(from: 0, to: 1)
                                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
                                .rotationEffect(.degrees(-90))
                            VStack {
                                Text("Done!")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .fontColor(.primary)
                                Text("🎉")
                                    .font(.title)
                                    .fontColor(.secondary)
                            }
                        }
                    } else {
                        ZStack {
                            Circle()
                                .stroke(Color.accentColor.opacity(0.2), lineWidth: 8)
                                .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
                            Circle()
                                .trim(from: 0, to: CGFloat(endTrainingGoal.getProgress()))
                                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
                                .rotationEffect(.degrees(-90))
                            VStack {
                                Text("\(endTrainingGoal.daysLeft())")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .fontColor(.primary)
                                Text("days left")
                                    .font(.caption)
                                    .fontColor(.secondary)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(FormattingUtils.formatMiles(endTrainingGoal.distance)) miles")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current")
                                    .font(.caption)
                                    .fontColor(.muted)
                                Text("\(FormattingUtils.secondsToFormattedTime(endTrainingGoal.currentTime))")
                                    .fontWeight(.bold)
                                    .fontColor(.secondary)
                            }
                            VStack(alignment: .leading) {
                                Text("Goal")
                                    .font(.caption)
                                    .fontColor(.muted)
                                Text("\(FormattingUtils.secondsToFormattedTime(endTrainingGoal.time))")
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
                .frame(height: 150)
            } else {
                VStack(spacing: 10) {
                    Text("No Training Goal Set")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontColor(.primary)
                    Text(
                        "A training goal can help you stay motivated and on track with your training to achieve your goals!"
                    )
                    .font(.body)
                    .fontColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    NavigationLink(destination: TrainingEndGoalSetupView()) {
                        Text("Setup Training Goal")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .enduraDefaultBox()
    }
}
