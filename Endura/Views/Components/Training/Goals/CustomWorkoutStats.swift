import Foundation
import SwiftUI

struct CustomWorkoutStats: View {
    private let workout: CustomWorkoutData

    init(_ workout: CustomWorkoutData) {
        self.workout = workout
    }

    var body: some View {
        VStack {
            ForEach(workout.blocks, id: \.self) { block in
                VStack {
                    ForEach(block.steps, id: \.self) { step in
                        VStack {
                            switch step.goal {
                            case .open:
                                Text("\(step.type.rawValue) Open")
                            case let .distance(distance):
                                Text("\(step.type.rawValue) \(FormattingUtils.formatMiles(distance)) miles")
                            case let .time(time):
                                Text("\(step.type.rawValue) \(FormattingUtils.secondsToFormattedTime(time))")
                            }
                        }
                        .padding(.leading, 10)
                        .fontColor(.secondary)
                    }
                }
            }
        }
    }
}
