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
//            ColoredBadge(trainingDay.type)
//                .alignFullWidth()
//                .padding(.top, -10)
//                .padding(.bottom, 10)
            if trainingDay.goals.isEmpty {
                Text(trainingDay
                    .type == .rest ?
                    "\(isToday ? "Today" : "This day") is a rest day, no goals for \(isToday ? "today" : "this day")!" :
                    "No goals for \(isToday ? "today" : "this day") yet!")
                    .font(.body)
                    .fontColor(.secondary)
                    //                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
            } else {
                VStack {
                    if trainingDay.type == .rest {
                        VStack {
                            Text("Rest Day")
                                .font(.title3)
                                .foregroundColor(Color("EnduraBlue").opacity(0.8))
//                                .fontWeight(.semibold)
                            Text("No goals for today, enjoy your rest day!")
                                .font(.body)
                                .fontColor(.secondary)
                                //                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    } else {
                        ForEach(trainingDay.goals, id: \.self) { goal in
                            TrainingGoal(goal)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $editSheet) {
            EditTrainingDayView(selectedDate: selectedDate)
        }
    }
}
