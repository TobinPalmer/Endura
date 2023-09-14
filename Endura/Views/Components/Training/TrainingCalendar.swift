import Foundation
import SwiftUI
import SwiftUICalendar

struct TrainingCalender: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    let controller = CalendarController()
    @Binding var selectedDate: YearMonthDay

    var body: some View {
        CalendarView(controller, header: { week in
            Text(week.shortString)
                .font(.subheadline)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }, component: { date in
            let trainingDay = activeUser.getTrainingDay(date)

            ZStack {
                Circle()
                    .fill(trainingDay.type.getColor().opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(trainingDay.type.getColor(), lineWidth: selectedDate == date ? 2 : 0)
                    )
                Text("\(date.day)")
                    .foregroundColor(trainingDay.type.getColor())
            }
            .padding(5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onTapGesture {
                selectedDate = date
            }
        })
        .padding(5)
    }
}
