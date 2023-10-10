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
                VStack {
                    Text("\(FormattingUtils.dateToFormattedDay(selectedDate))")
                        .font(.title)
                        .fontColor(.primary)
                        .fontWeight(.bold)
                }
                Spacer()
                Button(action: {
                    editSheet = true
                }) {
                    Text("Edit")
                }
            }
            ColoredBadge(trainingDay.type)
                .alignFullWidth()
                .padding(.top, -10)
                .padding(.bottom, 10)
            if trainingDay.goals.isEmpty {
                Text("No goals for \(isToday ? "today" : "this day")")
                    .font(.body)
                    .fontColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
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
