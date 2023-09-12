import Foundation
import SwiftUI
import SwiftUICalendar

struct TrainingCalender: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    let controller = CalendarController()
    @Binding var selectedDate: YearMonthDay

    init(_ date: Binding<YearMonthDay>) {
        _selectedDate = date
    }

    var body: some View {
        CalendarView(controller, header: { week in
            Text(week.shortString)
                .font(.subheadline)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }, component: { date in
            ZStack {
                Circle()
                    .fill(getDayType(date).getColor().opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(getDayType(date).getColor(), lineWidth: selectedDate == date ? 2 : 0)
                    )
                Text("\(date.day)")
                    .foregroundColor(getDayType(date).getColor())
            }
            .padding(5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onTapGesture {
                withAnimation {
                    selectedDate = date
                }
            }
        })
        .padding(5)
    }

    private func getDayType(_ date: YearMonthDay) -> TrainingDayType {
        activeUser.training[date]?.type ?? .none
    }
}
