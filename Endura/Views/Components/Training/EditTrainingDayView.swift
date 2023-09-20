import Foundation
import SwiftUI
import SwiftUICalendar

private final class TrainingDayViewModel: ObservableObject {}

struct TrainingDayView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @StateObject private var viewModel = TrainingDayViewModel()
    var selectedDate: YearMonthDay

    var body: some View {
        VStack {
            Text("Edit Training Plan for \(FormattingUtils.dateToFormattedDay(selectedDate))")
                .font(.title)
                .padding()
            Text("Current Plan")
                .font(.title2)
            let trainingDay = activeUser.getTrainingDay(selectedDate)
            Text("Day: \(trainingDay.type.rawValue)").foregroundColor(trainingDay.type.getColor())
            if trainingDay.goals.isEmpty {
                Text("No goals for this day")
            } else {
                ForEach(trainingDay.goals, id: \.self) { goal in
                    TrainingGoal(goal)
                }
            }
            Spacer()
        }
    }
}
