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
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20.0) {
                    TrainingCalender(controller: controller, selectedDate: $viewModel.selectedDate)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    TrainingGoalList(selectedDate: $viewModel.selectedDate)
                        .padding(.horizontal, 26)
                    NavigationLink(
                        destination: AddTrainingGoalView(viewModel.selectedDate)
                    ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("TextMuted"), style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .frame(height: 50)
                            HStack {
                                Image(systemName: "plus")
                                    .fontWeight(.bold)
                                    .fontColor(.muted)

                                Text("Add Goal")
                                    .fontWeight(.bold)
                                    .fontColor(.muted)
                            }
                        }
                    }
                    .padding(.horizontal, 26)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitle(FormattingUtils.fullFormattedDay(viewModel.selectedDate), displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(
                    destination: AddTrainingGoalView(viewModel.selectedDate)
                ) {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: GenerateTrainingGoalsView()
                ) {
                    Image(systemName: "sparkles")
                        .fontWeight(.bold)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: TrainingSettingsView()
                ) {
                    Image(systemName: "slider.horizontal.3")
                        .fontWeight(.bold)
                }
            }
        }
    }
}
