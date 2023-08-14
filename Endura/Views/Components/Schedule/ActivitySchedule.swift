//
// Created by Brandon Kirbyson on 7/26/23.
//

import Foundation
import SwiftUI

private struct MonthView: View {
    let dates: [Date]
    @Binding var selectedDate: Date?
    let events: [Date: String]

    var body: some View {
        VStack {
            LazyHGrid(rows: Array(repeating: .init(.flexible()), count: 1)) {
                ForEach(0 ..< 7, id: \.self) { index in
                    Text(Calendar.current.shortWeekdaySymbols[index]).padding(8)
                }
            }
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
                ForEach(dates, id: \.self) { date in
                    DayView(date: date,
                            isSelected: date == selectedDate,
                            event: events[date],
                            disabled: !isSameMonth(date1: date, date2: Date()))
                }
            }
        }
    }

    func isSameMonth(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let month1 = calendar.component(.month, from: date1)
        let month2 = calendar.component(.month, from: date2)
        return month1 == month2
    }
}

struct CalendarView: View {
    let months: [[Date]]
    @State var selectedDate: Date? = nil
    let events: [Date: String]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(months, id: \.self) { month in
                    MonthView(dates: month, selectedDate: $selectedDate, events: events)
                }
            }
        }
    }
}

struct ActivitySchedule: View {
    var body: some View {
        VStack {
            let currentMonthDates = CalendarUtils.generateCurrentMonthDates()
            CalendarView(months: [currentMonthDates], events: [Date(): "Event"])
        }
    }
}
