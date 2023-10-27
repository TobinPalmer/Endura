import Foundation
import SwiftUI

private struct RoutineGenerationInfo {
    var feeling: Feeling
    var hurtingParts: [BodyPart]
}

struct GenerateRoutineView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @Binding public var routineData: RoutineData
    @State private var routine: RoutineData

    @State private var generationInfo: RoutineGenerationInfo = .init(
        feeling: .good,
        hurtingParts: []
    )

    public init(_ routineData: Binding<RoutineData>) {
        _routineData = routineData
        _routine = State(initialValue: routineData.wrappedValue)
    }

    var body: some View {
        VStack {
            Text("How do you feel now after the run?")
                .font(.title)
                .fontWeight(.bold)
                .fontColor(.primary)

            Picker("Feeling", selection: $generationInfo.feeling) {
                ForEach(Feeling.allCases, id: \.self) { feeling in
                    Text(feeling.rawValue)
                        .foregroundColor(feeling.getColor())
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Text("Anything hurting or feeling sore?")
                .font(.title)
                .fontWeight(.bold)
                .fontColor(.primary)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
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
                            Text(bodyPart.rawValue)
                                .fontColor(generationInfo.hurtingParts.contains(bodyPart) ? .primary : .secondary)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(generationInfo.hurtingParts
                                            .contains(bodyPart) ? Color("TextMuted") : Color("Background"))
                                )
                        }
                    }
                }
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
