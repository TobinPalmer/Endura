import Combine
import Foundation
import SwiftUI

private final class RoutineTimerRingModel: ObservableObject {
    fileprivate func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        if minutes == 0 {
            return "\(seconds)"
        } else {
            return "\(minutes):\(seconds)"
        }
    }
}

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
    @StateObject private var viewModel = RoutineTimerRingModel()
    private var progress: Double {
        time / duration
    }

    @Binding private var time: Double
    private let duration: Double

    private let size: CGFloat

    public init(time: Binding<Double>, duration: Double, size: CGFloat = 300) {
        _time = time
        self.size = size
        self.duration = duration
    }

    var body: some View {
        let progressRingSize = size - 50
        ZStack {
            Circle()
                .stroke(Color.accentColor.opacity(0.2), lineWidth: 8)
                .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
            Circle()
                .trim(from: 0, to: min(CGFloat(progress), 1))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
                .rotationEffect(.degrees(-90))

            let done = duration - time == 0
            Text("\(done ? "Done" : viewModel.formatTime(duration - time))")
                .font(.system(size: done ? 25 : 50, weight: .bold, design: .rounded))
                .foregroundColor(Color.outlineRed)
        }
    }
}
