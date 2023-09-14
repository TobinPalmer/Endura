import Foundation
import SwiftUI
import SwiftUICalendar

private final class TrainingViewModel: ObservableObject {
    @Published public var selectedDate: YearMonthDay = .current
}

struct TrainingView: View {
    @StateObject private var viewModel = TrainingViewModel()

    var body: some View {
        VStack {
            Text("Training View")
            TrainingCalender(selectedDate: $viewModel.selectedDate)
            ScrollView {
                TrainingGoalList(selectedDate: $viewModel.selectedDate)
            }
        }
    }
}
