import Foundation
import SwiftUI
import SwiftUICalendar

private final class TrainingViewModel: ObservableObject {
    @Published public var selectedDate: YearMonthDay = .current
}

struct TrainingView: View {
    @StateObject private var viewModel = TrainingViewModel()
    @ObservedObject var controller = CalendarController()

    var body: some View {
        ScrollView {
            TrainingCalender(controller: controller, selectedDate: $viewModel.selectedDate)
            TrainingGoalList(selectedDate: $viewModel.selectedDate)
        }
        .navigationBarTitle("Training")
    }
}
