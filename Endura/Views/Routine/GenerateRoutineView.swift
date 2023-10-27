import Foundation
import SwiftUI

private struct RoutineGenerationInfo {
    var feeling: Double = 8
    var hurtingParts: [BodyPart] = []
    var notes: String = ""
}

struct GenerateRoutineView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @Binding public var routineData: RoutineData
    @State private var routine: RoutineData

    @State private var generationInfo: RoutineGenerationInfo = .init()

    public init(_ routineData: Binding<RoutineData>) {
        _routineData = routineData
        _routine = State(initialValue: routineData.wrappedValue)
    }

    var body: some View {
        VStack {
            ScrollView {
                Text("How are you feeling after your run?")
                    .font(.body)
                    .fontWeight(.bold)
                    .fontColor(.primary)
                    .alignFullWidth()

                Text("\(Int(generationInfo.feeling))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                    .foregroundColor(Color(
                        hue: 0.03 * generationInfo.feeling,
                        saturation: 1,
                        brightness: 0.8
                    ))
                Slider(value: $generationInfo.feeling, in: 0 ... 9, step: 1)
                    .accentColor(Color(
                        hue: 0.03 * generationInfo.feeling,
                        saturation: 1,
                        brightness: 0.8
                    ))
                HStack {
                    ForEach(
                        0 ..< 10,
                        id: \.self
                    ) { index in
                        Text("\(index + 1)")
                            .font(.caption)
                            .foregroundColor(Color(
                                hue: 0.03 * Double(index),
                                saturation: 1,
                                brightness: 0.8
                            ))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 20)

                Text("Anything hurting or feeling sore?")
                    .font(.body)
                    .fontWeight(.bold)
                    .fontColor(.primary)
                    .alignFullWidth()

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                            Button {
                                if generationInfo.hurtingParts.contains(bodyPart) {
                                    generationInfo.hurtingParts.removeAll {
                                        $0 == bodyPart
                                    }
                                } else {
                                    generationInfo.hurtingParts.append(bodyPart)
                                }
                            } label: {
                                let selected = generationInfo.hurtingParts.contains(bodyPart)
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(selected ? Color.orange : Color.clear)
                                    .frame(height: 50)
                                    .overlay {
                                        Text(bodyPart.rawValue)
                                            .foregroundColor(selected ? Color.white : Color("TextSecondary"))
                                            .fontWeight(selected ? .bold : .regular)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                    }
                            }
                        }
                    }
                }

                Text("Any other notes?")
                    .font(.body)
                    .fontWeight(.bold)
                    .fontColor(.primary)
                    .alignFullWidth()

                TextField("Notes", text: $generationInfo.notes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 20)
            }

            Button {
                Task {
                    let postRunRoutine = await TrainingGenerationUtils.generatePostRunRoutine(
                        activeUser: activeUser
                    )
                    if let postRunRoutine = postRunRoutine {
                        DispatchQueue.main.async {
                            self.routine = postRunRoutine
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate")
                }
            }
            .buttonStyle(EnduraNewButtonStyle())
        }
        .enduraPadding()
    }
}
