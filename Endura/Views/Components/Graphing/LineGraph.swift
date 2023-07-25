import SwiftUI

public struct LineGraph: View {
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
        let max = data.max() ?? 0
        let min = data.min() ?? 0
        let range = max - min

        GeometryReader { geometry in

            let frame = geometry.frame(in: .local)
            let stepWidth = frame.width / CGFloat(data.count - 1)
            let stepHeight = frame.height / CGFloat(range)

            Path { path in
                for index in data.indices {
                    let xPosition = stepWidth * CGFloat(index)
                    let yPosition = stepHeight * CGFloat((data[index] - min))

                    let point = CGPoint(x: xPosition, y: frame.height - yPosition)

                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
                .stroke(Color.primary, lineWidth: 2)
        }
    }
}
