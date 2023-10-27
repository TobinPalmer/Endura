import Foundation
import SwiftUI

public enum Feeling: String, CaseIterable {
    case reallyGood = "Really Good"
    case good = "Good"
    case okay = "Okay"
    case bad = "Bad"
    case reallyBad = "Really Bad"

    public func getColor() -> Color {
        switch self {
        case .reallyGood:
            return .green.darker()
        case .good:
            return .green
        case .okay:
            return .yellow
        case .bad:
            return .red
        case .reallyBad:
            return .red.darker()
        }
    }
}

public enum BodyPart: String, CaseIterable {
    case foot = "Foot"
    case ankle = "Ankle"
    case calf = "Calf"
    case shin = "Shin"
    case knee = "Knee"
    case thigh = "Thigh"
    case hip = "Hip"
    case groin = "Groin"
    case lowerBack = "Lower Back"
    case upperBack = "Upper Back"
    case shoulder = "Shoulder"
    case arm = "Arm"
    case toe = "Toe"
}
