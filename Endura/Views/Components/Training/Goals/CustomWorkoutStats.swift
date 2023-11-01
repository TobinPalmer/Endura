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
            VStack {
                ForEach(0 ..< workout.blocks.count, id: \.self) { blockIndex in
                    let block = workout.blocks[blockIndex]
                    VStack {
                        Text("Repeat \(block.iterations)x")
                            .font(.body)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                            .alignFullWidth()
                        VStack {
                            ForEach(block.steps, id: \.self) { step in
                                let color = step.type == .work ? Color("EnduraRed") : Color("EnduraGreen")
                                HStack {
                                    switch step.goal {
                                    case .open:
                                        Image(systemName: "circle")
                                    case .distance:
                                        Image(systemName: "figure.run")
                                    case .time:
                                        Image(systemName: "clock")
                                    }
                                    Text("\(step.type.rawValue)")
                                    Spacer()
                                    switch step.goal {
                                    case .open:
                                        Text("Open")
                                    case let .distance(distance):
                                        Text("\(Int(distance)) meters")
                                    case let .time(time):
                                        Text("\(FormattingUtils.secondsToFormattedTime(time, false))")
                                    }
                                }
                                .font(.body)
                                .fontColor(.primary)
                                .fontWeight(.bold)
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(color.opacity(0.4))
                                }
                            }
                        }
                        .padding(.leading, 10)
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("Background"))
                    }
//                    ForEach(0..<block.iterations, id: \.self) { _ in
//                        ScrollView([.horizontal], showsIndicators: false) {
//                    HStack {
//                        Text("\(block.iterations)x")
//                            .font(.body)
//                            .fontColor(.primary)
//                            .fontWeight(.bold)
//                        ForEach(block.steps, id: \.self) { step in
//                            if step != block.steps.first {
//                                Image(systemName: "arrow.right")
//                                    .font(.body)
//                                    .fontColor(.primary)
//                            }
//                            VStack {
//                                switch step.goal {
//                                case .open:
                    ////                                Image(systemName: "circle")
//                                    Text("\(step.type.rawValue)")
//                                    Text("Open")
//                                        .font(.body)
//                                        .fontColor(.primary)
//                                        .fontWeight(.regular)
//                                case let .distance(distance):
                    ////                                Image(systemName: "figure.run")
//                                    Text("\(step.type.rawValue)")
//                                    Text("\(FormattingUtils.formatMiles(distance)) miles")
//                                        .font(.body)
//                                        .fontColor(.primary)
//                                        .fontWeight(.regular)
//                                case let .time(time):
                    ////                                Image(systemName: "clock")
//                                    Text("\(step.type.rawValue)")
//                                    Text("\(FormattingUtils.secondsToFormattedTime(time))")
//                                        .font(.body)
//                                        .fontColor(.primary)
//                                        .fontWeight(.regular)
//                                }
//                            }
//                                .font(.caption)
//                                .fontColor(.muted)
//                                .fontWeight(.bold)
//                                .padding(.leading, 10)
//                                .fontColor(.primary)
//                        }
//                    }
//                        }
//                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
