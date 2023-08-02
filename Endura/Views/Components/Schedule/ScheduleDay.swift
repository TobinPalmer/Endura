//
// Created by Brandon Kirbyson on 7/26/23.
//

import Foundation
import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    private var date: Date

    init(day: Date) {
        date = day
    }

    struct DateUtils {
        static func startOfWeek(for date: Date) -> Date {
            var calendar = Calendar.current
            calendar.firstWeekday = 2 // Start on Monday
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
                fatalError("Could not determine the start of the week")
            }
            return weekInterval.start
        }
    }

    var body: some View {
        Button("Press to dismiss") {
            dismiss()
        }
        let todayDate = Calendar.current.dateComponents([.day], from: date)
        let startOfWeek = CalendarUtils.startOfWeek(for: date)
        let datesOfWeek = (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: startOfWeek)
        }
        VStack {
            ForEach(datesOfWeek, id: \.self) { date in
                let day = Calendar.current.component(.day, from: date)
                if day == todayDate.day! {
                    Text("\(day)")
                        .font(.title)
                        .padding()
                        .background(Color.yellow)
                } else {
                    Text("\(day)")
                        .font(.title)
                        .padding()
                }
            }
        }
    }
}

struct DayView: View {
    private let date: Date
    private let isSelected: Bool
    private let event: String?

    init(date: Date, isSelected: Bool, event: String?) {
        self.date = date
        self.isSelected = isSelected
        self.event = event
    }

    @State private var showingSheet = false

    var body: some View {
        VStack {
            Text("\(getDate())")
            event.map(Text.init)
        }
            .padding(8)
            .background(isToday() ? Color.green : (isSelected ? Color.blue : Color.white))
            .cornerRadius(10)
            .onTapGesture {
                showingSheet = true
            }
            .sheet(isPresented: $showingSheet) {
                SheetView(day: date)
            }
    }

    private func getDate() -> Int {
        let components = Calendar.current.dateComponents([.day], from: date)
        return components.day ?? 0
    }

    private func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
}
