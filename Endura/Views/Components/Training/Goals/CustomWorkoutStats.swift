import Foundation
import SwiftUI

struct CustomWorkoutStats: View {
    private let workout: CustomWorkoutData

    init(_ workout: CustomWorkoutData) {
        self.workout = workout
    }

    var body: some View {
        VStack(alignment: .leading) {
//            Text("Custom Workout Plan")
//                .font(.body)
//                .fontWeight(.bold)
//                .fontColor(.primary)
            ScrollView([.horizontal], showsIndicators: false) {
                HStack {
                    ForEach(workout.blocks, id: \.self) { block in
                        ForEach(0 ..< block.iterations, id: \.self) { _ in
                            ForEach(block.steps, id: \.self) { step in
                                if step != block.steps.first {
                                    Image(systemName: "arrow.right")
                                        .font(.body)
                                        .fontColor(.primary)
                                }
                                VStack {
                                    switch step.goal {
                                    case .open:
//                                Image(systemName: "circle")
                                        Text("\(step.type.rawValue)")
                                        Text("Open")
                                            .font(.body)
                                            .fontColor(.primary)
                                            .fontWeight(.regular)
                                    case let .distance(distance):
//                                Image(systemName: "figure.run")
                                        Text("\(step.type.rawValue)")
                                        Text("\(FormattingUtils.formatMiles(distance)) miles")
                                            .font(.body)
                                            .fontColor(.primary)
                                            .fontWeight(.regular)
                                    case let .time(time):
//                                Image(systemName: "clock")
                                        Text("\(step.type.rawValue)")
                                        Text("\(FormattingUtils.secondsToFormattedTime(time))")
                                            .font(.body)
                                            .fontColor(.primary)
                                            .fontWeight(.regular)
                                    }
                                }
                                .font(.caption)
                                .fontColor(.muted)
                                .fontWeight(.bold)
                                .padding(.leading, 10)
                                .fontColor(.primary)
                            }
                        }
                    }
                    Image(systemName: "arrow.right")
                        .font(.body)
                        .fontColor(.primary)
                    Text("Done!")
                        .font(.body)
                        .fontColor(.primary)
                        .fontWeight(.bold)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
