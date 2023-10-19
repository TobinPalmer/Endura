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

public enum RoutineExerciseParameter: Hashable, Codable {
    case time(TimeInterval)
    case count(Int)
    case distance(Int)
}

public enum RoutineType: String, Codable {
    case warmup = "Warm Up"
    case postRun = "Post Run"
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

public enum RoutineExerciseType: String, Hashable, Codable {
    /// Core Exercises
    case frontPlank = "Front Plank"
    case sidePlank = "Side Plank"
    case backPlank = "Back Plank"
    case otherSidePlank = "Other Side Plank"
    case gluteBridge = "Glute Bridge"
    case superman = "Superman"

    /// Legs Exercises
    case forwardLunge = "Forward Lunge"
    case forwardLungeWithTwist = "Forward Lunge With Twist"
    case sideLunge = "Side Lunge"
    case backAndToTheSideLunge = "Back and To The Side Lunge"
    case backwardLunge = "Backward Lunge"
    case squats = "Squats"
    case squattingCalfRaisesIn90DegreeSquatPosition = "Squatting Calf Raises in 90-Degree Squat Position"
    case legRaiseTo90DegreesWithBentKnee = "Leg Raise to 90 Degrees With Bent Knee"
    case kneeCirclesForward = "Knee Circles Forward"
    case kneeCirclesBackward = "Knee Circles Backward"
    case lateralLegRaise = "Lateral Leg Raise"
    case toeLungeWalk = "Toe Lunge Walk"
    case wideOuts = "Wide Outs"
    case waveLunge = "Wave Lunge"
    case mountainClimbersSinglesIn = "Mountain Climbers Singles In"
    case mountainClimbersSinglesOut = "Mountain Climbers Singles Out"
    case mountainClimbersDoublesIn = "Mountain Climbers Doubles In"
    case mountainClimbersDoublesOut = "Mountain Climbers Doubles Out"
    case sideSlide = "Side Slide"
    case sideJumpJacks = "Side Jump Jacks"

    /// Core and Leg Combined
    case vSitFlutterKicks = "V-Sit Flutter Kicks"
    case sidePlankLegLift = "Side Plank Leg Lift"
    case backPlankLegLift = "Back Plank Leg Lift"
    case pushUpToSidePlank = "Push Up to Side Plank"
    case vSitScissorKick = "V-Sit Scissor Kick"

    /// Glute and Leg Exercises
    case donkeyKicks = "Donkey Kicks"
    case donkeyWhips = "Donkey Whips"
    case fireHydrants = "Fire Hydrants"
    case reverseClams = "Reverse Clams"
    case reverseAirClams = "Reverse Air Clams"
    case clams = "Clams"

    /// Mobility and Stretching
    case inchWormsWithPushUp = "Inch Worms with Push Up"
    case birdDogSideExtension = "Bird Dog Side Extension"
    case bridgeWithHeelWalks = "Bridge with Heel Walks"
    case toeGrabPullForwardWithToesAndMoveForward = "Toe Grab Pull Forward with Toes and Move Forward"
    case toeWalk = "Toe Walk"
    case heelWalk = "Heel Walk"
    case barefootInPlace = "Barefoot In Place"
    case straightLegSpellAlphabet = "Straight Leg Spell Alphabet"
    case outsideOfFootWalk = "Outside of Foot Walk"
    case insideOfFootWalk = "Inside of Foot Walk"
    case toesInWalk = "Toes In Walk"
    case toesOutWalk = "Toes Out Walk"

    /// Walking Exercises
    case forwardWalk = "Forward Walk"
    case backwardWalk = "Backward Walk"
    case singleLegHops = "Single Leg Hops"
    case doubleLegHops = "Double Leg Hops"
    case forwardSkip = "Forward Skip"
    case backwardSkip = "Backward Skip"
    case crouchedWalk = "Crouched Walk"

    /// Upper Body Exercises
    case pushups = "Pushups"
    case rockies = "Rockies"
    case birdDog = "Bird Dog"

    /// Miscellaneous
    case runningVSits = "Running V-Sits"
    case australianCrawl = "Australian Crawl"
    case groinSplitters = "Groin Splitters"

    /// Level 3 Exercises
    case plankWithArmExtension = "Plank with Arm Extension"
    case vSitAlternatingKneeBend = "V-Sit Alternating Knee Bend"
    case squatWithArmExtension = "Squat with Arm Extension"
    case legExtensionsForwardAndBack = "Leg Extensions Forward and Back"
    case legExtensionsAt45DegreesForwardAndBack = "Leg Extensions at 45 Degrees Forward and Back"
    case kneeToChestExtension = "Knee to Chest Extension"
    case bentKneeLegExtension = "Bent Knee Leg Extension"
    case inAndOutLegExtensionWithBentKnee = "In and Out Leg Extension with Bent Knee"
    case yPullover = "Y-Pullover"
    case straightPullover = "Straight Pullover"

    /// Stretches
    case hamstringStretch = "Hamstring Stretch"
    case quadricepsStretch = "Quadriceps Stretch"
    case calfStretch = "Calf Stretch"
    case hipFlexorStretch = "Hip Flexor Stretch"
    case butterflyStretch = "Butterfly Stretch"
    case groinStretch = "Groin Stretch"
    case lowerBackStretch = "Lower Back Stretch"
    case tricepsStretch = "Triceps Stretch"
    case shoulderStretch = "Shoulder Stretch"
    case neckStretch = "Neck Stretch"
    case chestStretch = "Chest Stretch"
    case backStretch = "Back Stretch"
    case sideStretch = "Side Stretch"
    case wristFlexorStretch = "Wrist Flexor Stretch"
    case wristExtensorStretch = "Wrist Extensor Stretch"
    case ankleStretch = "Ankle Stretch"
    case innerThighStretch = "Inner Thigh Stretch"
}

public let postRunExerciseTypesString = """
public enum RoutineExerciseType: String, Hashable, Codable {
    /// Core Exercises
    case frontPlank = "Front Plank"
    case sidePlank = "Side Plank"
    case backPlank = "Back Plank"
    case otherSidePlank = "Other Side Plank"
    case gluteBridge = "Glute Bridge"
    case superman = "Superman"

    /// Legs Exercises
    case forwardLunge = "Forward Lunge"
    case forwardLungeWithTwist = "Forward Lunge With Twist"
    case sideLunge = "Side Lunge"
    case backAndToTheSideLunge = "Back and To The Side Lunge"
    case backwardLunge = "Backward Lunge"
    case squats = "Squats"
    case squattingCalfRaisesIn90DegreeSquatPosition = "Squatting Calf Raises in 90-Degree Squat Position"
    case legRaiseTo90DegreesWithBentKnee = "Leg Raise to 90 Degrees With Bent Knee"
    case kneeCirclesForward = "Knee Circles Forward"
    case kneeCirclesBackward = "Knee Circles Backward"
    case lateralLegRaise = "Lateral Leg Raise"
    case toeLungeWalk = "Toe Lunge Walk"
    case wideOuts = "Wide Outs"
    case waveLunge = "Wave Lunge"
    case mountainClimbersSinglesIn = "Mountain Climbers Singles In"
    case mountainClimbersSinglesOut = "Mountain Climbers Singles Out"
    case mountainClimbersDoublesIn = "Mountain Climbers Doubles In"
    case mountainClimbersDoublesOut = "Mountain Climbers Doubles Out"
    case sideSlide = "Side Slide"
    case sideJumpJacks = "Side Jump Jacks"

    /// Core and Leg Combined
    case vSitFlutterKicks = "V-Sit Flutter Kicks"
    case sidePlankLegLift = "Side Plank Leg Lift"
    case backPlankLegLift = "Back Plank Leg Lift"
    case pushUpToSidePlank = "Push Up to Side Plank"
    case vSitScissorKick = "V-Sit Scissor Kick"

    /// Glute and Leg Exercises
    case donkeyKicks = "Donkey Kicks"
    case donkeyWhips = "Donkey Whips"
    case fireHydrants = "Fire Hydrants"
    case reverseClams = "Reverse Clams"
    case reverseAirClams = "Reverse Air Clams"
    case clams = "Clams"

    /// Mobility and Stretching
    case inchWormsWithPushUp = "Inch Worms with Push Up"
    case birdDogSideExtension = "Bird Dog Side Extension"
    case bridgeWithHeelWalks = "Bridge with Heel Walks"
    case toeGrabPullForwardWithToesAndMoveForward = "Toe Grab Pull Forward with Toes and Move Forward"
    case toeWalk = "Toe Walk"
    case heelWalk = "Heel Walk"
    case barefootInPlace = "Barefoot In Place"
    case straightLegSpellAlphabet = "Straight Leg Spell Alphabet"
    case outsideOfFootWalk = "Outside of Foot Walk"
    case insideOfFootWalk = "Inside of Foot Walk"
    case toesInWalk = "Toes In Walk"
    case toesOutWalk = "Toes Out Walk"

    /// Walking Exercises
    case forwardWalk = "Forward Walk"
    case backwardWalk = "Backward Walk"
    case singleLegHops = "Single Leg Hops"
    case doubleLegHops = "Double Leg Hops"
    case forwardSkip = "Forward Skip"
    case backwardSkip = "Backward Skip"
    case crouchedWalk = "Crouched Walk"

    /// Upper Body Exercises
    case pushups = "Pushups"
    case rockies = "Rockies"
    case birdDog = "Bird Dog"

    /// Miscellaneous
    case runningVSits = "Running V-Sits"
    case australianCrawl = "Australian Crawl"
    case groinSplitters = "Groin Splitters"

    /// Level 3 Exercises
    case plankWithArmExtension = "Plank with Arm Extension"
    case vSitAlternatingKneeBend = "V-Sit Alternating Knee Bend"
    case squatWithArmExtension = "Squat with Arm Extension"
    case legExtensionsForwardAndBack = "Leg Extensions Forward and Back"
    case legExtensionsAt45DegreesForwardAndBack = "Leg Extensions at 45 Degrees Forward and Back"
    case kneeToChestExtension = "Knee to Chest Extension"
    case bentKneeLegExtension = "Bent Knee Leg Extension"
    case inAndOutLegExtensionWithBentKnee = "In and Out Leg Extension with Bent Knee"
    case yPullover = "Y-Pullover"
    case straightPullover = "Straight Pullover"

    /// Stretches
    case hamstringStretch = "Hamstring Stretch"
    case quadricepsStretch = "Quadriceps Stretch"
    case calfStretch = "Calf Stretch"
    case hipFlexorStretch = "Hip Flexor Stretch"
    case butterflyStretch = "Butterfly Stretch"
    case groinStretch = "Groin Stretch"
    case lowerBackStretch = "Lower Back Stretch"
    case tricepsStretch = "Triceps Stretch"
    case shoulderStretch = "Shoulder Stretch"
    case neckStretch = "Neck Stretch"
    case chestStretch = "Chest Stretch"
    case backStretch = "Back Stretch"
    case sideStretch = "Side Stretch"
    case wristFlexorStretch = "Wrist Flexor Stretch"
    case wristExtensorStretch = "Wrist Extensor Stretch"
    case ankleStretch = "Ankle Stretch"
    case innerThighStretch = "Inner Thigh Stretch"
}
"""
