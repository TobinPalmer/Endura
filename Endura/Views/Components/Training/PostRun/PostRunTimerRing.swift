import Combine
import Foundation
import SwiftUI

private final class PostRunTimerRingModel: ObservableObject {}

private extension Color {
    static var outlineRed: Color {
        Color(decimalRed: 34, green: 0, blue: 3)
    }

    static var darkRed: Color {
        Color(decimalRed: 221, green: 31, blue: 59)
    }

    static var lightRed: Color {
        Color(decimalRed: 239, green: 54, blue: 128)
    }

    init(decimalRed red: Double, green: Double, blue: Double) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255)
    }
}

struct PostRunTimerRing: View {
    @StateObject private var viewModel = PostRunTimerRingModel()
    @Binding private var progress: Double

    public init(progress: Binding<Double>) {
        _progress = progress
    }

    private var colors: [Color] = [Color.darkRed, Color.lightRed]

    var body: some View {
        let progress = progress / 10
        ZStack {
            Circle()
                .stroke(Color.outlineRed, lineWidth: 20)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: colors),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                ).rotationEffect(.degrees(-90))
            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(Color.darkRed)
                .offset(y: -150)
            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(progress > 0.95 ? Color.lightRed : Color.lightRed.opacity(0))
                .offset(y: -150)
                .rotationEffect(Angle.degrees(360 * Double(progress)))
                .shadow(color: progress > 0.96 ? Color.black.opacity(0.1) : Color.clear, radius: 3, x: 4, y: 0)
        }
        .frame(width: 300, height: 300)
        //      .animation(.spring(response: 0.6, dampingFraction: 1.0, blendDuration: 1.0), value: progress)
        .animation(.linear(duration: 1.0), value: progress)
    }
}
