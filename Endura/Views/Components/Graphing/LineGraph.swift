import SwiftUI

public struct LineGraph: View {
    @EnvironmentObject var viewModel: LineGraphViewModel

    private let data: [Double]
    private let height: Int
    private let valueModifier: (Double) -> String

    public init(data: [Double], height: Int = 200, valueModifier: @escaping (Double) -> String = { i in
        String(i)
    }) {
        self.data = data
        self.height = height
        self.valueModifier = valueModifier
    }

    public var body: some View {
        let maxVal = data.max() ?? 0
        let minVal = data.min() ?? 0
        let range = maxVal - minVal

        ZStack {
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

                if let touchLocation = viewModel.touchLocationX {
                    let index = min(max(Int((touchLocation / stepWidth).rounded()), 0), data.count - 1)
                    if let value = data[safe: index] {
                        let yPosition = stepHeight * CGFloat((value - minVal))

                        Circle()
                            .fill(Color.primary)
                            .frame(width: 10, height: 10)
                            .position(CGPoint(x: touchLocation, y: frame.height - yPosition))

                        Text("\(valueModifier(data[index]))")
                            .position(CGPoint(x: touchLocation, y: frame.height - yPosition - 30))

                    }
                }
            }
            Text("\(valueModifier(maxVal))")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .position(x: 10, y: 20)

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
