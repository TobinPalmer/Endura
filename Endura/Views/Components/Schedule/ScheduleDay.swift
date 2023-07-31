//
// Created by Brandon Kirbyson on 7/26/23.
//

import Foundation
import SwiftUI

struct DayView: View {
    let date: Date
    let isSelected: Bool
    let event: String?

    var body: some View {
        VStack {
            Text("\(getDate())")
            event.map(Text.init)
        }
                .padding(8)
                .background(isToday() ? Color.green : (isSelected ? Color.blue : Color.white))
                .cornerRadius(10)
    }

    func getDate() -> Int {
        let components = Calendar.current.dateComponents([.day], from: date)
        return components.day ?? 0
    }

    func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
}
