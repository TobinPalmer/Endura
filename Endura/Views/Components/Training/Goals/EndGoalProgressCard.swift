import Foundation
import SwiftUI

struct EndGoalProgressCard: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    public var endGoal: TrainingEndGoalData?

    @State private var deleteAlert: Bool = false

    var body: some View {
        VStack {
            if let endTrainingGoal = endGoal ?? activeUser.training.endTrainingGoal {
                let content = HStack(spacing: 10) {
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
                                Text("Goal")
                                    .font(.caption)
                                    .fontColor(.muted)
                                Text("\(FormattingUtils.secondsToFormattedTime(endTrainingGoal.time))")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("EnduraGreen"))
                            }
                            VStack(alignment: .leading) {
                                Text("Goal Pace")
                                    .font(.caption)
                                    .fontColor(.muted)
                                Text("\(ConversionUtils.convertMpsToMpm(endTrainingGoal.pace * 1609.344)) /mi")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("EnduraGreen"))
                            }
                            .padding(.leading, 6)
                        }
                        .padding(.leading, 6)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current")
                                    .font(.caption)
                                    .fontColor(.muted)
                                Text("\(FormattingUtils.secondsToFormattedTime(endTrainingGoal.currentTime))")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("EnduraYellow"))
//                                    .fontColor(.secondary)
                            }
//                            VStack(alignment: .leading) {
//                                Text("Current Pace")
//                                    .font(.caption)
//                                    .fontColor(.muted)
//                                Text("\(ConversionUtils.convertMpsToMpm(endTrainingGoal.distance * 1609.344 /
//                                endTrainingGoal.currentTime)) /mi")
//                                    .fontWeight(.bold)
//                                    .fontColor(.secondary)
//                            }
                        }
                        .padding(.leading, 6)
                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 150)
                if endGoal == nil {
                    NavigationLink(destination: TrainingEndGoalSetupView(endTrainingGoal)) {
                        content
                            .frame(maxWidth: .infinity)
                            .enduraDefaultBox()
                    }
                } else {
                    content
                }
            } else {
                VStack(spacing: 10) {
                    Text("No Training Goal Set")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontColor(.primary)
                    Text(
                        "A training goal can help you stay motivated and on track with your training to achieve your goals!"
                    )
                    .font(.system(size: 16))
                    .fontColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    NavigationLink(destination: TrainingEndGoalSetupView()) {
                        Text("Setup Training Goal")
                    }
                }
                .padding(.vertical, 10)
                .enduraDefaultBox()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .contextMenu {
            Button {
                deleteAlert = true
            } label: {
                Label("Remove Training Goal", systemImage: "trash")
            }
        }
        .alert(isPresented: $deleteAlert) {
            Alert(
                title: Text("Remove Training Goal"),
                message: Text("Are you sure you want to remove your training goal?"),
                primaryButton: .destructive(Text("Remove")) {
                    activeUser.training.endTrainingGoal = nil
                },
                secondaryButton: .cancel()
            )
        }
    }
}
