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
    private let colors: [Color] = [Color.red, Color.blue]
    private let type: GoalRingType

    public init(_ type: GoalRingType) {
        self.type = type
    }

    public var body: some View {
        ZStack {
            Text("28.5/30")
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
