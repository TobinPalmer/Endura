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
            let trainingDay = activeUser.getTrainingDay(selectedDate)
            Text("Day: \(trainingDay.type.rawValue)").foregroundColor(trainingDay.type.getColor())
            if trainingDay.goals.isEmpty {
                Text("No goals for \(isToday ? "today" : "this day")")
            } else {
                ForEach(trainingDay.goals, id: \.self) { goal in
                    TrainingGoal(goal)
                }
            }
//            TrainingGoal(TrainingGoalData.warmup(time: 10, count: 1))
//            TrainingGoal(TrainingGoalData.run(
//                distance: 5.03,
//                pace: 6,
//                time: 30,
//                difficulty: .hard,
//                runType: .long
//            ))
//            TrainingGoal(TrainingGoalData.postRun(time: 10, count: 1))
        }
    }
}
