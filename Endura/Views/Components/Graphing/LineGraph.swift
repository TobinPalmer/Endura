import SwiftUI

public struct LineGraph: View {
    @EnvironmentObject var viewModel: LineGraphViewModel

    private let data: [(Date, Double)]
    private let step: Int
    private let height: Int
    private let valueModifier: (Double) -> String

    public init(data: [(Date, Double)], step: Int, height: Int = 200, valueModifier: @escaping (Double) -> String = { i in
        String(i)
    }) {
        self.data = data
        self.step = step
        self.height = height
        self.valueModifier = valueModifier
    }

    public var body: some View {
        let maxVal = data.max(by: { $0.1 < $1.1 })?.1 ?? 0
        let minVal = data.min(by: { $0.1 < $1.1 })?.1 ?? 0
        let range = maxVal - minVal

        let minTimestamp = data.min(by: { $0.0 < $1.0 })?.0 ?? Date()
        let maxTimestamp = data.max(by: { $0.0 < $1.0 })?.0 ?? Date()
        let timestampRange = maxTimestamp.timeIntervalSince(minTimestamp)

        ZStack {
            GeometryReader { geometry in
                let frame = geometry.frame(in: .local)
                let stepHeight = frame.height / CGFloat(range)

                Path { path in
                    var previousDate: Date?
                    for index in data.indices {
                        let proportionOfTimestampInRange = data[index].0.timeIntervalSince(minTimestamp) / timestampRange
                        let xPosition = frame.width * CGFloat(proportionOfTimestampInRange)
                        let yPosition = stepHeight * CGFloat((data[index].1 - minVal))

                        let point = CGPoint(x: xPosition, y: frame.height - yPosition)


                        if let previousDate = previousDate, data[index].0.timeIntervalSince(previousDate) > Double(step * 2) {
                            path.move(to: point)
                        } else if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }

                        previousDate = data[index].0
                    }
                }
                        .stroke(Color.primary, lineWidth: 2)

                let minTimestampInterval: Double = minTimestamp.timeIntervalSince1970

                if let touchLocation = viewModel.touchLocationX {
                    let touchTimestamp = minTimestampInterval + Double(touchLocation / geometry.size.width) * timestampRange
                    let closestDate = data.min(by: { abs($0.0.timeIntervalSince1970 - touchTimestamp) < abs($1.0.timeIntervalSince1970 - touchTimestamp) }) ?? data.last ?? (Date(), 0)
                    let yPosition = stepHeight * CGFloat((closestDate.1 - minVal))


                    if abs(closestDate.0.timeIntervalSince1970 - touchTimestamp) > Double(step * 2) {
                        Circle()
                                .fill(Color.primary)
                                .frame(width: 10, height: 10)
                                .position(CGPoint(x: touchLocation, y: geometry.size.height))

                        Text("Paused")
                                .position(CGPoint(x: touchLocation, y: geometry.size.height - 30))
                    } else {
                        Circle()
                                .fill(Color.primary)
                                .frame(width: 10, height: 10)
                                .position(CGPoint(x: touchLocation, y: geometry.size.height - yPosition))

                        Text("\(valueModifier(closestDate.1))")
                                .position(CGPoint(x: touchLocation, y: geometry.size.height - yPosition - 30))
                    }
                }

            }

            Text("\(valueModifier((maxVal + minVal) / 2))")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .position(x: 10, y: CGFloat(height) / 2)

            Text("\(valueModifier(minVal))")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .position(x: 10, y: CGFloat(height) - 20)
        }
                .padding(0)
                .frame(height: CGFloat(height))
                .background(Color.clear)
                .contentShape(Rectangle())
    }
}
