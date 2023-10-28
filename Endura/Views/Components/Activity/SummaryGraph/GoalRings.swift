import Foundation
import SwiftUI

private final class GoalRingModel: ObservableObject {}

public enum GoalRingType {
    case distance
    case time
    case calories
}

struct GoalRing: View {
    @StateObject private var viewModel = GoalRingModel()
    private let colors: [Color] = [Color("EnduraRed"), Color("EnduraBlue")]
    private let type: GoalRingType

    private var goal: String {
        switch type {
        case .distance:
            return "30"
        case .time:
            return "4:00:00"
        case .calories:
            return "3000"
        }
    }

    private var current: String {
        switch type {
        case .distance:
            return "20.1"
        case .time:
            return "3:05:21"
        case .calories:
            return "2072"
        }
    }

    public init(_ type: GoalRingType) {
        self.type = type
    }

    public var body: some View {
        ZStack {
            Text(current + " / " + goal)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(5)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .padding(5)

            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: colors),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}
