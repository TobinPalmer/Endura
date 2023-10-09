import Foundation
import SwiftUI
import SwiftUICalendar

struct TrainingGoalList: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @Binding var selectedDate: YearMonthDay
    var isToday: Bool {
        selectedDate == .current
    }

    @State private var editSheet = false

    init(selectedDate: Binding<YearMonthDay> = .constant(.current)) {
        _selectedDate = selectedDate
    }

    var body: some View {
        VStack {
            let trainingDay = activeUser.training.getTrainingDay(selectedDate)
            HStack {
                Text("\(FormattingUtils.dateToFormattedDay(selectedDate))")
                    .font(.title)
                ColoredBadge(trainingDay.type)
                Spacer()
                Button(action: {
                    editSheet = true
                }) {
                    Text("Edit")
                }
            }
            Text("Day: \(trainingDay.type.rawValue)").foregroundColor(trainingDay.type.getColor())
            if trainingDay.goals.isEmpty {
                Text("No goals for \(isToday ? "today" : "this day")")
            } else {
                VStack {
                    ForEach(trainingDay.goals, id: \.self) { goal in
                        TrainingGoal(goal)
                    }
                }
            }
        }
        .sheet(isPresented: $editSheet) {
            EditTrainingDayView(selectedDate: selectedDate)
        }
    }
}
