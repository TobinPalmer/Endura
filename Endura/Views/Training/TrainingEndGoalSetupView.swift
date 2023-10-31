import Foundation
import SwiftUI
import SwiftUICalendar

struct TrainingEndGoalSetupView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State private var endGoal: TrainingEndGoalData
    @Environment(\.dismiss) private var dismiss

    public init(_ endGoal: TrainingEndGoalData? = nil) {
        _endGoal = State(initialValue: endGoal ?? .init(
            date: .current,
            startDate: .current.addDay(value: 7),
            distance: 1,
            time: 8,
            currentTime: 9,
            completed: false
        ))
    }

    @State private var verifySaveAlert = false

    var body: some View {
        ZStack {
//            Color("Background")
//                .ignoresSafeArea()

            VStack {
                List {
                    Section(header: Text(""), footer: Text("The date you want to complete your goal by.")) {
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

                    Section {
                        HStack {
                            Label("Distance", systemImage: "ruler")

                            Spacer()

                            DistanceInput(
                                distance: $endGoal.distance
                            )
                        }

                        HStack {
                            Label("Time", systemImage: "stopwatch")

                            Spacer()

                            TimeInput(
                                time: $endGoal.time
                            )
                        }
                    }

                    Section {
                        Text("What your goal will look like:")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                        EndGoalProgressCard(endGoal: endGoal)
                    }
                }
                Button {
                    verifySaveAlert = true
                } label: {
                    Text("Save")
                }
                .buttonStyle(EnduraNewButtonStyle())
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
            }
            .navigationBarTitle("Setup your Training Goal")
            .alert(isPresented: $verifySaveAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("This will change your current training goal."),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Save"), action: {
                        activeUser.training.endTrainingGoal = endGoal
                        dismiss()
                    })
                )
            }
        }
    }
}
