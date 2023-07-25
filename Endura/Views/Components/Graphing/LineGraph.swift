import SwiftUI

public struct LineGraph: View {
    @State private var touchLocation: CGFloat? = nil

    private let data: [Double]

    public init(data: [Double]) {
        self.data = data
    }

    public init(data: [Int]) {
        self.data = data.map {
            Double($0)
        }
    }

    public var body: some View {
        let maxVal = data.max() ?? 0
        let minVal = data.min() ?? 0
        let range = maxVal - minVal

        VStack {
            GeometryReader { geometry in
                let frame = geometry.frame(in: .local)
                let stepWidth = frame.width / CGFloat(data.count - 1)
                let stepHeight = frame.height / CGFloat(range)

                Path { path in
                    for index in data.indices {
                        let xPosition = stepWidth * CGFloat(index)
                        let yPosition = stepHeight * CGFloat((data[index] - minVal))

                        let point = CGPoint(x: xPosition, y: frame.height - yPosition)

                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                }
                    .stroke(Color.primary, lineWidth: 2)

                if let touchLocation = touchLocation {
                    let index = min(max(Int((touchLocation / stepWidth).rounded()), 0), data.count - 1)
                    let value = data[index]
                    let yPosition = stepHeight * CGFloat((value - minVal))

                    Circle()
                        .fill(Color.primary)
                        .frame(width: 10, height: 10)
                        .position(CGPoint(x: touchLocation, y: frame.height - yPosition))

                    Text("\(data[index])")
                        .position(CGPoint(x: touchLocation, y: frame.height - yPosition - 30))
                }
            }
        }
            .background(Color.clear)
            .frame(height: 200)
            .border(Color.red)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    self.touchLocation = value.location.x
                })
                .onEnded({ _ in
                    self.touchLocation = nil
                })
            )
    }
}
