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
//                        RoundedRectangle(cornerRadius: 10)
                    Circle()
                        .fill(trainingDay.type.getColor().opacity(0.2))
                        .overlay(
                            //                                RoundedRectangle(cornerRadius: 10)
                            Circle()
                                .stroke(trainingDay.type.getColor(), lineWidth: selectedDate == date ? 2 : 0)
                        )
                    VStack {
                        Text("\(date.day)")
                            .foregroundColor(trainingDay.type.getColor())
                    }
                    .overlay {
                        ZStack {
                            if date.getDate() < YearMonthDay.current.getDate(), trainingDay.type != .none {
                                if !trainingDay.goals.isEmpty && trainingDay.goals
                                    .allSatisfy({ $0.progress.workoutCompleted }) || trainingDay.type == .rest
                                {
                                    Circle()
                                        .fill(Color("Background"))
                                        .frame(width: 15, height: 15)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("EnduraGreen"))
                                } else if !trainingDay.goals.isEmpty {
                                    Circle()
                                        .fill(Color("Background"))
                                        .frame(width: 15, height: 15)
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color("EnduraRed"))
                                }
                            } else if date == .current {
                                Circle()
                                    .fill(Color("Background"))
                                    .frame(width: 15, height: 15)
                                Image(systemName: "star.circle.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .font(.system(size: 16))
                        .frame(width: 16, height: 16, alignment: .topTrailing)
                        .offset(x: 16, y: -16)
                    }
                }
                .padding(5)
                .opacity(date.isFocusYearMonth! ? 1 : 0.5)
                //                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .frame(width: 50, height: 50, alignment: .center)
                .onTapGesture {
                    selectedDate = date
                }
            })
            .onChange(of: controller.yearMonth) { _, newMonth in
                activeUser.training.loadTrainingMonth(newMonth)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 400, maxHeight: 400)
        .padding(20)
        .enduraDefaultBox()
    }
}
