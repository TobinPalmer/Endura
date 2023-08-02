//
// Created by Brandon Kirbyson on 7/26/23.
//

import Foundation
import SwiftUI

//struct CalanderPopupSheetView: View {
//    @Environment(\.dismiss) var dismiss
//    private var date: Date
//
//    init(day: Date) {
//        date = day
//    }
//
//    var body: some View {
//        Button("Press to dismiss") {
//            dismiss()
//        }
//        let todayDate = Calendar.current.dateComponents([.day], from: date)
//        let startOfWeek = CalendarUtils.startOfWeek(for: date)
//        let datesOfWeek = (0..<7).compactMap {
//            Calendar.current.date(byAdding: .day, value: $0, to: startOfWeek)
//        }
//        HStack {
//            ForEach(datesOfWeek, id: \.self) { date in
//                let day = Calendar.current.component(.day, from: date)
//                if day == todayDate.day! {
//                    Text("\(day)")
//                        .font(.title3)
//                        .padding()
//                        .background(Color.yellow)
//                } else {
//                    Text("\(day)")
//                        .font(.title3)
//                        .padding()
//                }
//            }
//        }
//        Text("Current Date: \(date)")
//        Spacer()
//    }
//}

struct CalanderPopupSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var date: Date

    init(day: Date) {
        _date = State(initialValue: day)
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
        HStack {
            ForEach(datesOfWeek, id: \.self) { date in
                let day = Calendar.current.component(.day, from: date)
                Button {
                    self.date = date
                }
                label: {
                    if day == todayDate.day! {
                        Text("\(day)")
                            .padding()
                            .background(Color.yellow)
                    } else {
                        Text("\(day)")
                            .padding()
                            .background(isSameMonth(date1: date, date2: Date()) ? Color.white : Color.gray)
                    }
                }
                    .disabled(!isSameMonth(date1: date, date2: Date()))
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        Text("Current Date: \(date)")
        Spacer()
    }

    func isSameMonth(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let month1 = calendar.component(.month, from: date1)
        let month2 = calendar.component(.month, from: date2)
        return month1 == month2
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
                CalanderPopupSheetView(day: date)
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
