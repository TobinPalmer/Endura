import Foundation
import SwiftUI
import SwiftUICalendar

struct TrainingGoalList: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @Binding var selectedDate: YearMonthDay
    var isToday: Bool {
        selectedDate == .current
    }

    init(selectedDate: Binding<YearMonthDay> = .constant(.current)) {
        _selectedDate = selectedDate
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(FormattingUtils.dateToFormattedDay(selectedDate))")
                    .font(.title)
                Spacer()
                NavigationLink(destination: TrainingDayView(selectedDate: selectedDate)) {
                    Text("Edit")
                }
            }
            .padding()
            let trainingDay = activeUser.training.getTrainingDay(selectedDate)
            Text("Day: \(trainingDay.type.rawValue)").foregroundColor(trainingDay.type.getColor())
            if trainingDay.goals.isEmpty {
                Text("No goals for \(isToday ? "today" : "this day")")
            } else {
                VStack {
                    ForEach(trainingDay.goals, id: \.self) { goal in
                        TrainingGoal(goal)
                    }
                }
                .padding(20)
            }
        }
    }
}
