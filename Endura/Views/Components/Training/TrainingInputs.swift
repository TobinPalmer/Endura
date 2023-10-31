import Foundation
import SwiftUI

struct DistanceInput: View {
    @Binding var distance: Double

    @State private var popup = false

    var body: some View {
        Button {
            popup = true
        } label: {
            Text(FormattingUtils.formatMiles(distance))
                .font(.title3)
                .fontWeight(.bold)
        }
        .popover(isPresented: $popup) {
//            HStack {
//                Button(action: {
//                    distance -= 1
//                }) {
//                    Image(systemName: "minus")
//                }
//                TextField("Distance", value: Binding(
//                    get: { distance },
//                    set: { newValue in
//                        distance = Double(newValue)
//                    }
//                ), format: .number)
//                    .multilineTextAlignment(.center)
//                    .keyboardType(.decimalPad)
//                    .fontColor(.primary)
//                Button(action: {
//                    distance += 1
//                }) {
//                    Image(systemName: "plus")
//                }
//            }
//            .font(.largeTitle)
//            .fontWeight(.bold)
//            .padding(16)
//            .presentationCompactAdaptation(.popover)
            HStack(spacing: 0) {
                let width = CGFloat(90)
                Picker("", selection: Binding(
                    get: {
                        Int(distance)
                    },
                    set: { newValue in
                        distance = Double(newValue) + distance.truncatingRemainder(dividingBy: 1)
                    }
                )) {
                    ForEach(0 ..< 100) { index in
                        Text("\(index)")
                            .tag(index)
                    }
                }
                .frame(width: width)
                .pickerStyle(WheelPickerStyle())
                .clipShape(.rect.offset(x: -16))
                .padding(.trailing, -16)
                Picker("", selection: Binding(
                    get: {
                        Int((distance.truncatingRemainder(dividingBy: 1) * 10.0).rounded())
                    },
                    set: { newValue in
                        distance = Double(Int(distance)) + Double(newValue) / 10.0
                    }
                )) {
                    ForEach(0 ..< 10) { index in
                        Text("\(index)")
                            .tag(index)
                    }
                }
                .frame(width: width)
                .pickerStyle(WheelPickerStyle())
                .clipShape(.rect.offset(x: 16))
                .padding(.leading, -16)
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .padding(16)
            .presentationCompactAdaptation(.popover)
        }
    }
}

struct TimeInput: View {
    @Binding var time: Double
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var seconds: Int = 0

    private let displayHours: Bool

    @State private var popup = false

    init(time: Binding<Double>, hours: Bool = false) {
        displayHours = hours
        _time = time
        _hours = State(initialValue: Int(time.wrappedValue / 3600))
        _minutes = State(initialValue: Int(time.wrappedValue / 60) % 60)
        _seconds = State(initialValue: Int(time.wrappedValue) % 60)
    }

    var body: some View {
        Button {
            popup = true
        } label: {
            Text(FormattingUtils.secondsToFormattedTime(time))
                .font(.title3)
                .fontWeight(.bold)
        }
        .popover(isPresented: $popup) {
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
            .padding(16)
            .presentationCompactAdaptation(.popover)
        }
    }
}

struct EditCustomWorkout: View {
    @Binding var workoutData: CustomWorkoutData

    @State var data: CustomWorkoutData

    init(data: Binding<CustomWorkoutData>) {
        _workoutData = data
        _data = State(initialValue: data.wrappedValue)
    }

    var body: some View {
        VStack {
            ForEach(0 ..< data.blocks.count, id: \.self) { blockIndex in
                let block = data.blocks[blockIndex]
                VStack {
                    HStack {
                        Text("Block \(blockIndex + 1)")

                        Spacer()

                        Stepper(value: Binding(
                            get: { data.blocks[blockIndex].iterations },
                            set: { newValue in
                                data.blocks[blockIndex].iterations = newValue
                            }
                        ), in: 1 ... 50) {
                            Text("x\(data.blocks[blockIndex].iterations)")
                        }
                    }

                    ForEach(0 ..< block.steps.count, id: \.self) { stepIndex in
                        let step = block.steps[stepIndex]
                        VStack {
                            Picker("Goal", selection: Binding(
                                get: { step.goal },
                                set: { newValue in
                                    data.blocks[blockIndex].steps[stepIndex].goal = newValue
                                }
                            )) {
                                Text("Open").tag(CustomWorkoutStepGoal.open)
                                Text("Distance").tag(CustomWorkoutStepGoal.distance(distance: 0))
                                Text("Time").tag(CustomWorkoutStepGoal.time(time: 0))
                            }
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
                        }
                        .padding(16)
                        .enduraDefaultBox()
                    }

                    Button("Add Step") {
                        data.blocks[blockIndex].steps.append(CustomWorkoutStepData(type: .work, goal: .open))
                    }
                }
                .padding(16)
                .enduraDefaultBox()
            }

            Button("Add Block") {
                data.blocks.append(CustomWorkoutBlockData(steps: [], iterations: 1))
            }
        }
        .onChange(of: data) { _, newValue in
            workoutData = newValue
        }
    }
}
