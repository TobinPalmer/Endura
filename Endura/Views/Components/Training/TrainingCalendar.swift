import Foundation
import SwiftUI
import SwiftUICalendar

private final class TrainingViewModel: ObservableObject {
    @Published fileprivate var loadedMonths: [YearMonth] = []
}

struct TrainingCalender: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @StateObject private var viewModel = TrainingViewModel()
    @ObservedObject var controller: CalendarController
    @Binding var selectedDate: YearMonthDay

    var body: some View {
        VStack {
            Button {
                activeUser.training.monthlyTrainingData[.current]?.days.updateValue(
                    DailyTrainingData(date: selectedDate.addDay(value: 1), type: .workout, goals: []),
                    forKey: selectedDate.addDay(value: 1)
                )
            } label: {
                Text("test")
            }

            HStack(alignment: .center, spacing: 0) {
                Button("Prev") {
                    controller.scrollTo(controller.yearMonth.addMonth(value: -1), isAnimate: true)
                }
                .padding(26)
                Spacer()
                HStack {
                    Button {
                        controller.scrollTo(.current, isAnimate: true)
                    } label: {
                        Image(systemName: "calendar").font(.title2)
                    }
                    Text("\(controller.yearMonth.monthShortString), \(String(controller.yearMonth.year))")
                        .font(.title)
                }
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                Spacer()
                Button("Next") {
                    controller.scrollTo(controller.yearMonth.addMonth(value: 1), isAnimate: true)
                }
                .padding(26)
            }
            CalendarView(controller, startWithMonday: true, header: { week in
                Text(week.shortString)
                    .font(.subheadline)
            },
            component: { date in
                let trainingDay = activeUser.training.getTrainingDay(date)

                ZStack {
                    Circle()
                        .fill(trainingDay.type.getColor().opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(trainingDay.type.getColor(), lineWidth: selectedDate == date ? 2 : 0)
                        )
                    Text("\(date.day)")
                        .foregroundColor(trainingDay.type.getColor())
                }
                .padding(5)
                .opacity(date.isFocusYearMonth! ? 1 : 0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .onTapGesture {
                    selectedDate = date
                }
            })
            .onChange(of: controller.yearMonth) { newMonth in
                activeUser.training.loadMonth(newMonth)
            }
            .padding(26)
        }
        .frame(maxWidth: .infinity, minHeight: 400, maxHeight: 400)
    }
}
