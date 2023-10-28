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
            return Color("EnduraGreen").darker()
        case .good:
            return Color("EnduraGreen")
        case .okay:
            return Color("EnduraYellow")
        case .bad:
            return Color("EnduraRed")
        case .reallyBad:
            return Color("EnduraRed").darker()
        }
    }
}

public enum BodyPart: String, CaseIterable {
    case foot = "Foot"
    case ankle = "Ankle"
    case calf = "Calf"
    case shin = "Shin"
    case heel = "Heel"
    case knee = "Knee"
    case thigh = "Thigh"
    case hip = "Hip"
    case groin = "Groin"
    case back = "Back"
    case shoulder = "Shoulder"
    case arm = "Arm"
}
