import Foundation
import SwiftUI
import SwiftUICalendar

struct TrainingCalender: View {
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
                    .fill(getColor(date).opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(getColor(date), lineWidth: selectedDate == date ? 2 : 0)
                    )
                Text("\(date.day)")
                    .foregroundColor(getColor(date))
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

    private func getColor(_ date: YearMonthDay) -> Color {
        if date.dayOfWeek == .sun {
            return Color.red
        } else if date.dayOfWeek == .sat {
            return Color.blue
        } else {
            return Color.accentColor
        }
    }
}
