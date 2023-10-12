import Foundation
import SwiftUI

struct DistanceInput: View {
    @Binding var distance: Double

    var body: some View {
        HStack {
            Button(action: {
                distance -= 1
            }) {
                Image(systemName: "minus")
            }
            TextField("Distance", value: Binding(
                get: { distance },
                set: { newValue in
                    distance = Double(newValue)
                }
            ), format: .number)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .fontColor(.primary)
            Button(action: {
                distance += 1
            }) {
                Image(systemName: "plus")
            }
        }
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(26)
    }
}

struct TimeInput: View {
    @Binding var time: Double
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var seconds: Int = 0

    init(time: Binding<Double>) {
        _time = time
        _hours = State(initialValue: Int(time.wrappedValue / 3600))
        _minutes = State(initialValue: Int(time.wrappedValue / 60) % 60)
        _seconds = State(initialValue: Int(time.wrappedValue) % 60)
    }

    var body: some View {
        HStack(spacing: 0) {
            let width = CGFloat(90)
            Picker("Hours", selection: Binding(
                get: { Int(time / 3600) },
                set: { newValue in
                    time = time + Double(-hours * 3600 + newValue * 3600)
                    hours = newValue
                }
            )) {
                ForEach(0 ..< 24) { index in
                    Text("\(index)h")
                        .tag(index)
                }
            }
            .frame(width: width)
            .pickerStyle(WheelPickerStyle())
            .clipShape(.rect.offset(x: -16))
            .padding(.trailing, -16)
            Picker("Minutes", selection: Binding(
                get: { Int(time / 60) % 60 },
                set: { newValue in
                    time = time + Double(-minutes * 60 + newValue * 60)
                    minutes = newValue
                }
            )) {
                ForEach(0 ..< 60) { index in
                    Text("\(index)m")
                        .tag(index)
                }
            }
            .frame(width: width)
            .pickerStyle(WheelPickerStyle())
            .clipShape(.rect.offset(x: -16))
            .padding(.trailing, -16)
            .clipShape(.rect.offset(x: 16))
            .padding(.leading, -16)
            Picker("Seconds", selection: Binding(
                get: { Int(time) % 60 },
                set: { newValue in
                    time = time + Double(-seconds + newValue)
                    seconds = newValue
                }
            )) {
                ForEach(0 ..< 60) { index in
                    Text("\(index)s")
                        .tag(index)
                }
            }
            .frame(width: width)
            .pickerStyle(WheelPickerStyle())
            .clipShape(.rect.offset(x: 16))
            .padding(.leading, -16)
        }
        .frame(maxWidth: .infinity, maxHeight: 100)
        .padding(.top, 8)
    }
}

struct EditCustomWorkout: View {
    @Binding var data: CustomWorkoutData

    var body: some View {
        VStack {
            ForEach(data.blocks.indices, id: \.self) { blockIndex in
                let block = data.blocks[blockIndex]
                ForEach(block.steps.indices, id: \.self) { stepIndex in
                    let step = block.steps[stepIndex]
                    if step.type == .work {
                        switch step.goal {
                        case .open:
                            Text("Open")
                        case let .distance(distance):
                            Text("Distance: \(distance)")
                            DistanceInput(distance: Binding(
                                get: { distance },
                                set: { newValue in
                                    data.blocks[blockIndex].steps[stepIndex].goal = .distance(distance: newValue)
                                }
                            ))
                        case let .time(time):
                            Text("Time: \(time)")
                            TimeInput(time: Binding(
                                get: { time },
                                set: { newValue in
                                    data.blocks[blockIndex].steps[stepIndex].goal = .time(time: newValue)
                                }
                            ))
                        }
                    } else {
                        Text("Break")
                    }
                }

                Button("Add Step") {
                    data.blocks[blockIndex].steps.append(CustomWorkoutStepData(type: .work, goal: .open))
                }
            }

            Button("Add Block") {
                data.blocks.append(CustomWorkoutBlockData(steps: [], iterations: 1))
            }
        }
    }
}
