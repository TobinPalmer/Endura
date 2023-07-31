//
// Created by Brandon Kirbyson on 7/26/23.
//

import Foundation
import SwiftUI

fileprivate struct MonthView: View {
    let dates: [Date]
    @Binding var selectedDate: Date?
    let events: [Date: String]

    fileprivate var body: some View {
        VStack {
            LazyHGrid(rows: Array(repeating: .init(.flexible()), count: 1)) {
                ForEach(0..<7, id: \.self) { index in
                    Text(Calendar.current.shortWeekdaySymbols[index]).padding(8)
                }
            }
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
                ForEach(dates, id: \.self) { date in
                    DayView(date: date, isSelected: date == selectedDate, event: events[date])
                }
            }
        }
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
