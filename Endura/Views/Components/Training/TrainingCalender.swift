import Foundation
import SwiftUI
import SwiftUICalendar

struct TrainingCalender: View {
    var body: some View {
        VStack {
            CalendarView { date in
                Text("Day \(date.day)")
            }
        }
    }
}
