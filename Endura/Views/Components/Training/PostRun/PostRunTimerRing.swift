import Foundation
import SwiftUI

private final class PostRunTimerRingModel: ObservableObject {}

struct PostRunTimerRing: View {
    @StateObject private var viewModel = PostRunTimerRingModel()

    private let duration: TimeInterval
    private let currentTime: TimeInterval
    private let lineWidth: CGFloat
    private let gradient: Gradient

    public init(duration: TimeInterval, currentTime: TimeInterval, lineWidth: CGFloat, gradient: Gradient) {
        self.duration = duration
        self.currentTime = currentTime
        self.lineWidth = lineWidth
        self.gradient = gradient
    }

    public var body: some View {
        let progress = duration == 0 ? 0 : currentTime / duration
        Circle()
            .rotation(.degrees(-90))
            .trim(from: 0, to: CGFloat(progress))
            .stroke(
                AngularGradient(gradient: gradient,
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(progress * 360 - 90)),
                style: .init(lineWidth: lineWidth, lineCap: .round)
            )
            .overlay(
                GeometryReader { _ in
                    Circle()
                        .fill(gradient.stops[1].color)
                        .frame(width: lineWidth, height: lineWidth)
                        //            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        //            .offset(x: min(geometry.size.width, geometry.size.height) / 2)
                        .rotationEffect(.degrees(progress * 360 - 90))
                        .shadow(color: .black, radius: lineWidth / 2, x: 0, y: 0)
                }
                .clipShape(
                    Circle()
                        .rotation(.degrees(-90 + progress * 360 - 0.5))
                        .trim(from: 0, to: 0.25)
                        .stroke(style: .init(lineWidth: lineWidth))
                )
            )
            .scaledToFit()
            //      .padding(lineWidth / 2)
            .animation(.linear(duration: currentTime), value: currentTime)
            .frame(width: 200, height: 200)
    }
}
