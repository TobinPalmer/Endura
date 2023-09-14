import Foundation
import SwiftUI
import SwiftUICalendar

struct TrainingGoalList: View {
    @Binding var selectedDate: YearMonthDay

    init(selectedDate: Binding<YearMonthDay> = .constant(.current)) {
        _selectedDate = selectedDate
    }

    var body: some View {
        VStack {
            Text("Day: \(selectedDate.day)")
            TrainingGoal(TrainingGoalData.warmup(time: 10, count: 1))
            TrainingGoal(TrainingGoalData.run(
                distance: 5.03,
                pace: 6,
                time: 30,
                difficulty: .hard,
                runType: .long
            ))
            TrainingGoal(TrainingGoalData.postRun(time: 10, count: 1))
        }
    }
}
