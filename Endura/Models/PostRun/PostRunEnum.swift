import Foundation
import SwiftUI

public enum RoutineExerciseBenefit: String {
    case legs = "Legs"
    case arms = "Arms"
    case core = "Core"
    case cardio = "Cardio"
    case coreAndLegs = "Core and Legs"
    case glutesAndLegs = "Glutes and Legs"
    case mobilityAndStretching = "Mobility and Stretching"
    case upperBody = "Upper Body"
    case stretching = "Stretching"
    case none
}

public enum RoutineExerciseParameter: Hashable {
    case time(TimeInterval)
    case count(Int)
    case distance(Int)
}

public struct RoutineExercise: Hashable {
    var type: RoutineExerciseType
    var parameter: RoutineExerciseParameter
}

public enum RoutineType: String, Codable {
    case warmup = "Warm Up"
    case postrun = "Post Run"
}

public enum RoutineDifficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case none

    public func getColor() -> Color {
        switch self {
        case .easy:
            return .green
        case .medium:
            return .yellow
        case .hard:
            return .red
        case .none:
            return .clear
        }
    }
}

public enum RoutineExerciseType: Hashable {
    /// Core Exercises
    case frontPlank
    case sidePlank
    case backPlank
    case otherSidePlank
    case gluteBridge
    case superman

    /// Legs Exercises
    case forwardLunge
    case forwardLungeWithTwist
    case sideLunge
    case backAndToTheSideLunge
    case backwardLunge
    case squats
    case squattingCalfRaisesIn90DegreeSquatPosition
    case legRaiseTo90DegreesWithBentKnee
    case kneeCirclesForward
    case kneeCirclesBackward
    case lateralLegRaise
    case toeLungeWalk
    case wideOuts
    case waveLunge
    case mountainClimbersSinglesIn
    case mountainClimbersSinglesOut
    case mountainClimbersDoublesIn
    case mountainClimbersDoublesOut
    case sideSlide
    case sideJumpJacks

    /// Core and Leg Combined
    case vSitFlutterKicks
    case sidePlankLegLift
    case backPlankLegLift
    case pushUpToSidePlank
    case vSitScissorKick

    /// Glute and Leg Exercises
    case donkeyKicks
    case donkeyWhips
    case fireHydrants
    case reverseClams
    case reverseAirClams
    case clams

    /// Mobility and Stretching
    case inchWormsWithPushUp
    case birdDogSideExtension
    case bridgeWithHeelWalks
    case toeGrabPullForwardWithToesAndMoveForward
    case toeWalk
    case heelWalk
    case barefootInPlace
    case straightLegSpellAlphabet
    case outsideOfFootWalk
    case insideOfFootWalk
    case toesInWalk
    case toesOutWalk

    /// Walking Exercises
    case forwardWalk
    case backwardWalk
    case singleLegHops
    case doubleLegHops
    case forwardSkip
    case backwardSkip
    case crouchedWalk

    /// Upper Body Exercises
    case pushups
    case rockies
    case birdDog

    /// Miscellaneous
    case runningVSits
    case australianCrawl
    case groinSplitters

    /// Level 3 Exercises
    case plankWithArmExtension
    case vSitAlternatingKneeBend
    case squatWithArmExtension
    case legExtensionsForwardAndBack
    case legExtensionsAt45DegreesForwardAndBack
    case kneeToChestExtension
    case bentKneeLegExtension
    case inAndOutLegExtensionWithBentKnee
    case yPullover
    case straightPullover

    /// Stretches
    case hamstringStretch
    case quadricepsStretch
    case calfStretch
    case hipFlexorStretch
    case butterflyStretch
    case groinStretch
    case lowerBackStretch
    case tricepsStretch
    case shoulderStretch
    case neckStretch
    case chestStretch
    case backStretch
    case sideStretch
    case wristFlexorStretch
    case wristExtensorStretch
    case ankleStretch
    case innerThighStretch
}
