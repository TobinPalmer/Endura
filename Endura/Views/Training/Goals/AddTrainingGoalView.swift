import Foundation
import SwiftUI
import SwiftUICalendar

struct AddTrainingGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    public var selectedDate: YearMonthDay

    init(_ selectedDate: YearMonthDay) {
        self.selectedDate = selectedDate
    }

    var body: some View {
        ScrollView {
            Text("Add Training Goal")
                .font(.title)
                .fontWeight(.bold)
                .fontColor(.primary)
                .padding()
            Text("Select a type of goal to add.")
                .font(.title2)
                .fontColor(.secondary)
                .padding()

            VStack {
                ForEach(WorkoutGoalData.allCases, id: \.self) { goal in
                    NavigationLink(destination: EditRunningTrainingGoalView(goal: TrainingRunGoalData(
                        date: selectedDate,
                        workout: goal
                    ))) {
                        AddTrainingGoalTypeCard(
                            icon: goal.getWorkoutIcon(),
                            title: goal.getWorkoutName(),
                            description: goal.getWorkoutDescription()
                        )
                    }
                }
            }
        }
    }
}

struct AddTrainingGoalTypeCard: View {
    private let icon: String
    private let title: String
    private let description: String

    public init(icon: String, title: String, description: String) {
        self.title = title
        self.description = description
        self.icon = icon
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
                .fontWeight(.bold)
            VStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontColor(.primary)
                    .padding()
                Text(description)
                    .font(.body)
                    .fontColor(.secondary)
                    .padding()
            }
        }
        .alignFullWidth()
        .padding(26)
        .enduraDefaultBox()
    }
}
