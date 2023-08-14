import SwiftUI

public protocol LineGraphStyle {
    var color: Color { get }
}

struct PaceLineGraphStyle: LineGraphStyle {
    public let color: Color = .blue
}

struct HeartRateLineGraphStyle: LineGraphStyle {
    public let color: Color = .red
}

struct LineSegment: Shape {
    var start, end: CGPoint

    func path(in _: CGRect) -> Path {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
    }
}

extension LineSegment {
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get {
            AnimatablePair(start.animatableData, end.animatableData)
        }
        set {
            (start.animatableData, end.animatableData) = (newValue.first, newValue.second)
        }
    }
}

struct AnimatedPath: View {
    @State private var drawPercent: CGFloat = 0
    let path: Path
    let color: Color
    let duration: Double

    var body: some View {
        path.trim(from: 0, to: drawPercent)
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .foregroundColor(color)
            .onAppear {
                withAnimation(.linear(duration: self.duration)) {
                    self.drawPercent = 1
                }
            }
    }
}

struct LineGraph<Style>: View where Style: LineGraphStyle {
    @EnvironmentObject var activityViewModel: ActivityViewModel

    private let style: Style

    private let data: [(Date, Double)]
    private let step: Int
    private let height: Int
    private let valueModifier: (Double) -> String

    public init(data: LineGraphData, step: Int, height: Int = 200, valueModifier: @escaping (Double) -> String = { i in
        String(i)
    }, style: Style) {
        self.data = data
        self.step = step
        self.height = height
        self.valueModifier = valueModifier
        self.style = style
    }

    var body: some View {
        let maxVal = data.max(by: { $0.1 < $1.1 })?.1 ?? 0
        let minVal = data.min(by: { $0.1 < $1.1 })?.1 ?? 0
        let range = maxVal - minVal
        let mean = data.reduce(0) { $0 + $1.1 } / Double(data.count)

        let minTimestamp = data.min(by: { $0.0 < $1.0 })?.0 ?? Date()
        let minTimestampInterval: Double = minTimestamp.timeIntervalSince1970
        let maxTimestamp = data.max(by: { $0.0 < $1.0 })?.0 ?? Date()
        let timestampRange = maxTimestamp.timeIntervalSince(minTimestamp)

        GeometryReader { geometry in
            ZStack {
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .local)
                    let stepHeight = frame.height / CGFloat(range)
                    let path = self.createPath(from: data, in: frame, with: step, minVal: minVal, range: range, minTimestamp: minTimestamp, timestampRange: timestampRange)

                    AnimatedPath(path: path, color: style.color, duration: 2)
                }

                Text("\(valueModifier(mean))")
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
            .padding(10)
            .frame(height: CGFloat(height))
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let x = value.location.x
                    if let hitPoint = data.first(where: { point in
                        let proportionOfTimestampInRange = point.0.timeIntervalSince(minTimestamp) / timestampRange
                        let xPosition = geometry.frame(in: .local).width * CGFloat(proportionOfTimestampInRange)
                        return x < xPosition
                    }) {
                        activityViewModel.analysisPosition = hitPoint.0
                    }
                }
                .onEnded { _ in
                    activityViewModel.analysisPosition = nil
                }
            )
        }
        .frame(height: CGFloat(height))
    }

    func createPath(from data: [(Date, Double)], in frame: CGRect, with step: Int, minVal: Double, range: Double, minTimestamp: Date, timestampRange: Double) -> Path {
        var path = Path()
        var previousDate: Date?
        for index in data.indices {
            let proportionOfTimestampInRange = data[index].0.timeIntervalSince(minTimestamp) / timestampRange
            let xPosition = frame.width * CGFloat(proportionOfTimestampInRange)
            let yPosition = frame.height * CGFloat((data[index].1 - minVal) / range)

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
        // Close path at the bottom of the graph
//        path.addLine(to: CGPoint(x: path.currentPoint!.x, y: frame.height))
//        path.addLine(to: CGPoint(x: 0, y: frame.height))
//        path.closeSubpath()
        return path
    }
}
