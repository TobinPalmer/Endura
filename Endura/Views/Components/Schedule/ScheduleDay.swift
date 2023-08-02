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
    private let disabled: Bool

    init(date: Date, isSelected: Bool, event: String?, disabled: Bool = false) {
        self.date = date
        self.isSelected = isSelected
        self.event = event
        self.disabled = disabled
    }

    @State private var showingSheet = false

    var body: some View {
        VStack {
            Text("\(getDate())")
            event.map(Text.init)
        }
            .padding(8)
            .background(Color(disabled ? .gray : (isToday() ? .green : (isSelected ? .blue : .white))))
            .cornerRadius(10)
            .onTapGesture {
                if !disabled {
                    showingSheet = true
                }
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
