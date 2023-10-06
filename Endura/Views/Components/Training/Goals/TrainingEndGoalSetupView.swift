import Foundation
import SwiftUI
import SwiftUICalendar

struct TrainingEndGoalSetupView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State private var endGoal: TrainingEndGoalData = .init(
        date: .current,
        startDate: .current.addDay(value: 7),
        distance: 1,
        time: 8,
        currentTime: 9,
        completed: false
    )

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
//                    VStack {
//                        Text("Set a goal!")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .fontColor(.primary)
//                            .padding(.bottom, 8)
//
//                        Text("Set a goal for yourself to work towards!")
//                            .font(.caption)
//                            .fontColor(.secondary)
//                            .padding(.bottom, 16)
//                    }

                    VStack(alignment: .leading, spacing: 2) {
                        DatePicker(
                            selection: Binding<Date>(
                                get: { endGoal.date.getDate() },
                                set: { endGoal.date = $0.toYearMonthDay() }
                            ),
                            in: Date()...,
                            displayedComponents: [.date]
                        ) {
                            Label("Completion Date", systemImage: "calendar")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(26)
                    .enduraDefaultBox()

                    VStack(alignment: .leading, spacing: 2) {
                        Label("Distance", systemImage: "figure.walk")

                        DistanceInput(
                            distance: Binding<Double>(
                                get: { endGoal.distance },
                                set: { endGoal.distance = $0 }
                            )
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(26)
                    .enduraDefaultBox()

                    VStack(alignment: .leading, spacing: 2) {
                        Label("Time", systemImage: "stopwatch")

                        TimeInput(
                            time: Binding<Double>(
                                get: { endGoal.time },
                                set: { endGoal.time = $0 }
                            )
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(26)
                    .enduraDefaultBox()

                    Button {
                        print("Set Goal")
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(EnduraNewButtonStyle())
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitle("Setup your Training Goal")
            .enduraPadding()
        }
    }
}
