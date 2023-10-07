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
            HStack(alignment: .center, spacing: 0) {
                Button(action: {
                    controller.scrollTo(controller.yearMonth.addMonth(value: -1), isAnimate: true)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Spacer()
                HStack {
                    Button {
                        controller.scrollTo(.current, isAnimate: true)
                    } label: {
                        Image(systemName: "calendar").font(.title2)
                    }
                    Text("\(controller.yearMonth.monthShortString), \(String(controller.yearMonth.year))")
                        .font(.title)
                        .fontWeight(.bold)
                        .fontColor(.primary)
                }
                Spacer()
                Button(action: {
                    controller.scrollTo(controller.yearMonth.addMonth(value: 1), isAnimate: true)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            CalendarView(controller, startWithMonday: true, headerSize: .fixHeight(20.0), header: { week in
                Text(week.shortString)
                    .font(.subheadline)
                    .fontColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
            },
            component: { date in
                let trainingDay = activeUser.training.getTrainingDay(date)

                ZStack {
//                    Circle()
//                        .fill(trainingDay.type.getColor().opacity(0.2))
//                        .overlay(
//                            Circle()
//                                .stroke(trainingDay.type.getColor(), lineWidth: selectedDate == date ? 2 : 0)
//                        )
                    RoundedRectangle(cornerRadius: 10)
                        .fill(trainingDay.type.getColor().opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
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
            .onChange(of: controller.yearMonth) { _, newMonth in
                activeUser.training.loadTrainingMonth(newMonth)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 400, maxHeight: 400)
    }
}
