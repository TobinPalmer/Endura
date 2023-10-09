import Foundation
import SwiftUI

struct ColoredBadge: View {
    private let text: String
    private let color: Color

    init(text: String, color: Color) {
        self.text = text
        self.color = color
    }

    init(_ trainingType: TrainingDayType) {
        if trainingType == .none {
            text = ""
        } else {
            text = trainingType.rawValue
        }
        color = trainingType.getColor()
    }

    var body: some View {
        if !text.isEmpty {
            Text(text)
                .font(.system(size: 14))
                .fontWeight(.bold)
                .foregroundColor(color)
                .padding(.horizontal, 10)
                .frame(height: 25)
                .background {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(color.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(color, lineWidth: 1)
                        )
                }
        }
    }
}
