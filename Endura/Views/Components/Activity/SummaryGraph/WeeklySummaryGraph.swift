import Foundation
#if canImport(Charts)
import Charts
#endif

import SwiftUI

private final class WeeklySumaryGraphModel: ObservableObject {
  @Published var day: Days = .monday
  @Published var location: CGPoint = .zero
}

struct WeeklySummaryGraph: View {
  @StateObject private var viewModel = WeeklySumaryGraphModel()
  private var data: [WeeklyGraphData]

  init(_ data: [WeeklyGraphData]) {
    self.data = data

    let mergedData = data.reduce(into: [WeeklyGraphData]()) { mergedData, currentData in
      if let existingIndex = mergedData.firstIndex(where: { $0.day == currentData.day }) {
        mergedData[existingIndex].distance += currentData.distance
      } else {
        mergedData.append(WeeklyGraphData(day: currentData.day, distance: currentData.distance))
      }
    }

    let presentDays = Set(mergedData.map {
      $0.day
    })

    let missingDays = Set(Days.allCases).subtracting(presentDays)

    let missingData = missingDays.map {
      WeeklyGraphData(day: $0, distance: 0)
    }
    let updatedData = mergedData + missingData

    let dayOrder: [Days] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    let sortedData = updatedData.sorted {
      dayOrder.firstIndex(of: $0.day)! < dayOrder.firstIndex(of: $1.day)!
    }

    self.data = sortedData
  }


  public var body: some View {
    VStack {
      Text("Weekly Summary Graph")
      if #available(iOS 16.0, *) {
        Chart {
          ForEach(data, id: \.self) { data in
            BarMark(
              x: .value("Week", data.day.rawValue),
              y: .value("Miles", data.distance)
            )
          }
        }
          .chartOverlay { proxy in
            GeometryReader { geometry in
              Rectangle().fill(.clear).contentShape(Rectangle())
                .gesture(
                  DragGesture()
                    .onChanged { value in
                      let origin = geometry[proxy.plotAreaFrame].origin
                      let location = CGPoint(
                        x: value.location.x - origin.x,
                        y: value.location.y - origin.y
                      )
                      let (day, distance) = proxy.value(at: location, as: ((String, Double).self)) ?? ("", 0)
                      viewModel.day = Days(rawValue: day) ?? .monday
                      viewModel.location = location
                      print("Location: \(location), Day: \(day), Distance: \(distance)")
                    }
                )
            }

            let graphWidth = proxy.plotAreaSize.width
            let textPosition: Double;
            switch viewModel.day {
            case .monday:
              let _ = textPosition = 0
            case .tuesday:
              let _ = textPosition = graphWidth / 7
            case .wednesday:
              let _ = textPosition = graphWidth / 7 * 2
            case .thursday:
              let _ = textPosition = graphWidth / 7 * 3
            case .friday:
              let _ = textPosition = graphWidth / 7 * 4
            case .saturday:
              let _ = textPosition = graphWidth / 7 * 5
            case .sunday:
              let _ = textPosition = graphWidth / 7 * 6
            }
            Text("\(viewModel.day.rawValue): \(data.first(where: { $0.day == viewModel.day })?.distance ?? 0, specifier: "%.2f") miles")
              .frame(maxWidth: .infinity, alignment: .center)
              .position(
                x: textPosition,
                y: -50
              )
              .font(.title3)
              .fontWeight(.semibold)
          }
      } else {
        Text("This week you ran 27.8 miles")
      }
    }
      .frame(width: 250, height: 250)
  }
}
