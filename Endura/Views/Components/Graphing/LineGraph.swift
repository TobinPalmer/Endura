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

struct ElevationLineGraphStyle: LineGraphStyle {
    public let color: Color = .gray
}

struct CadenceLineGraphStyle: LineGraphStyle {
    /// #871C46
    public let color: Color = .init(red: 0.5294117647, green: 0.1098039216, blue: 0.2745098039)
}

struct PowerLineGraphStyle: LineGraphStyle {
    /// #CEF350
    public let color: Color = .init(red: 0.8078431373, green: 0.9529411765, blue: 0.3137254902)
}

struct GroundContactTimeLineGraphStyle: LineGraphStyle {
    /// #0094ff
    public let color: Color = .init(red: 0, green: 0.5803921569, blue: 1)
}

struct StrideLengthLineGraphStyle: LineGraphStyle {
    /// #FFB900
    public let color: Color = .init(red: 1, green: 0.7254901961, blue: 0)
}

struct VerticalOscillationLineGraphStyle: LineGraphStyle {
    /// #FFB900
    public let color: Color = .init(red: 1, green: 0.7254901961, blue: 0)
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
    let fill: Bool

    var body: some View {
        path.trim(from: 0, to: drawPercent)
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            //            .fill(fill ? color.opacity(0.35) : Color.clear)
            .foregroundColor(color)
            .onAppear {
                withAnimation(.linear(duration: duration)) {
                    self.drawPercent = 1
                }
            }
    }
}

struct DraggableModifier: ViewModifier {
    enum Direction {
        case vertical
        case horizontal
    }

    let direction: Direction
    @State private var draggedOffset: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .offset(
                CGSize(width: direction == .vertical ? 0 : draggedOffset.width,
                       height: direction == .horizontal ? 0 : draggedOffset.height)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.draggedOffset = value.translation
                    }
                    .onEnded { _ in
                        self.draggedOffset = .zero
                    }
            )
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
        if !data.isEmpty {
            let maxVal = data.max(by: { $0.1 < $1.1 })?.1 ?? 0
            let minVal = data.min(by: { $0.1 < $1.1 })?.1 ?? 0
            let range = maxVal - minVal
            let mean = data.reduce(0) {
                $0 + $1.1
            } / Double(data.count)

            let minTimestamp = data.min(by: { $0.0 < $1.0 })?.0 ?? Date()
            let maxTimestamp = data.max(by: { $0.0 < $1.0 })?.0 ?? Date()
            let timestampRange = maxTimestamp.timeIntervalSince(minTimestamp)

            GeometryReader { geometry in
                ZStack {
                    GeometryReader { geometry in
                        let frame = geometry.frame(in: .local)
                        let paths = createPaths(from: data, in: frame, with: step, minVal: minVal, range: range, minTimestamp: minTimestamp, timestampRange: timestampRange)

                        ForEach(0 ..< paths.endIndex, id: \.self) { i in
                            let path = paths[i]
                            path
                                .foregroundColor(style.color.opacity(0.5))
                                .opacity(activityViewModel.analysisValue != nil ? 0.75 : 1) // 75% of original (0.5)
                                .overlay(
                                    LineSegment(start: CGPoint(x: activityViewModel.analysisValue ?? 0, y: 0), end: CGPoint(x: activityViewModel.analysisValue ?? 0, y: frame.height))
                                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                        .foregroundColor(.black)
                                        .opacity(activityViewModel.analysisValue != nil ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.5), value: activityViewModel.analysisValue)
                                )
                                .frame(maxWidth: .infinity)
                        }
                    }

                    if activityViewModel.analysisValue != nil {
                        let proportionOfTimestampInRange = activityViewModel.analysisValue! / geometry.frame(in: .local).width
                        let xPosition = geometry.frame(in: .local).width * CGFloat(proportionOfTimestampInRange)
                        let yPosition = geometry.frame(in: .local).height * CGFloat((data.first(where: { point in
                            let proportionOfTimestampInRange = point.0.timeIntervalSince(minTimestamp) / timestampRange
                            let xPosition = geometry.frame(in: .local).width * CGFloat(proportionOfTimestampInRange)
                            return activityViewModel.analysisValue! < xPosition
                        })?
                            .1 ?? 0 - minVal) / range)

                        let valueAtXPosition = data.first(where: { point in
                            let proportionOfTimestampInRange = point.0.timeIntervalSince(minTimestamp) / timestampRange
                            let xPosition = geometry.frame(in: .local).width * CGFloat(proportionOfTimestampInRange)
                            return activityViewModel.analysisValue! < xPosition
                        })?
                            .1 ?? 0

                        let valueAtXPositionString = valueModifier(valueAtXPosition)

                        Text(valueAtXPositionString)
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
                .frame(height: CGFloat(height))
                .gesture(DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        let x = value.location.x
                        if let hitPoint = data.first(where: { point in
                            let proportionOfTimestampInRange = point.0.timeIntervalSince(minTimestamp) / timestampRange
                            let xPosition = geometry.frame(in: .local).width * CGFloat(proportionOfTimestampInRange)
                            return x < xPosition
                        }) {
                            activityViewModel.analysisPosition = hitPoint.0
                            activityViewModel.analysisValue = value.location.x
                        }
                    }
                    .onEnded { _ in
                        activityViewModel.analysisValue = nil
                        activityViewModel.analysisPosition = nil
                    }
                )
            }
            .frame(height: CGFloat(height))
        } else {
            EmptyView()
        }
    }

//    func createPath(from data: [(Date, Double)], in frame: CGRect, with step: Int, minVal: Double, range: Double, minTimestamp: Date, timestampRange: Double) -> Path {
//        var path = Path()
//        var previousDate: Date?
//        for index in data.indices {
//            let proportionOfTimestampInRange = data[index].0.timeIntervalSince(minTimestamp) / timestampRange
//            let xPosition = frame.width * CGFloat(proportionOfTimestampInRange)
//            let yPosition = frame.height * CGFloat((data[index].1 - minVal) / range)
//
//            let point = CGPoint(x: xPosition, y: frame.height - yPosition)
//
//            if let previousDate = previousDate, data[index].0.timeIntervalSince(previousDate) > Double(step * 2) {
//                path.move(to: point)
//            } else if index == 0 {
//                path.move(to: point)
//            } else {
//                path.addLine(to: point)
//            }
//            previousDate = data[index].0
//        }
//        // Close path at the bottom of the graph
//        path.addLine(to: CGPoint(x: path.currentPoint!.x, y: frame.height))
//        path.addLine(to: CGPoint(x: 0, y: frame.height))
//        path.closeSubpath()
//        return path
//    }

    func createPath(from data: [(Date, Double)], in frame: CGRect, with step: Int, minVal: Double, range: Double, minTimestamp: Date, timestampRange: Double) -> [Path] {
        var paths = [Path]()
        var previousDate: Date?
        for index in data.indices {
            let proportionOfTimestampInRange = data[index].0.timeIntervalSince(minTimestamp) / timestampRange
            let xPosition = frame.width * CGFloat(proportionOfTimestampInRange)
            let yPosition = frame.height * CGFloat((data[index].1 - minVal) / range)

            let point = CGPoint(x: xPosition, y: frame.height - yPosition)

            var path = Path()
            if let previousDate = previousDate, data[index].0.timeIntervalSince(previousDate) > Double(step * 2) {
                path.move(to: point)
            } else if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            path.addLine(to: CGPoint(x: path.currentPoint!.x, y: frame.height))
            path.addLine(to: CGPoint(x: 0, y: frame.height))
            path.closeSubpath()
            paths.append(path)

            previousDate = data[index].0
        }
        return paths
    }

    func createPaths(from data: [(Date, Double)], in frame: CGRect, with _: Int, minVal: Double, range: Double, minTimestamp: Date, timestampRange: Double) -> [Path] {
        var paths: [Path] = []
        var previousPoint: CGPoint?
        for index in data.indices {
            let proportionOfTimestampInRange = data[index].0.timeIntervalSince(minTimestamp) / timestampRange
            let xPosition = frame.width * CGFloat(proportionOfTimestampInRange)
            let yPosition = frame.height * CGFloat((data[index].1 - minVal) / range)

            let point = CGPoint(x: xPosition, y: frame.height - yPosition)
            var path = Path()
            if let previousPoint = previousPoint {
                if previousPoint.x > 0 && previousPoint.x < frame.width {
                    path.move(to: previousPoint)
                    path.addLine(to: point)
                    path.addLine(to: CGPoint(x: point.x, y: frame.height))
                    path.addLine(to: CGPoint(x: previousPoint.x, y: frame.height))
                    path.closeSubpath()
                }
            }
            previousPoint = point
            paths.append(path)
        }
        return paths
    }
}
