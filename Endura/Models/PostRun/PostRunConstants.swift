import Foundation
import SwiftUI

public let routineExerciseReference: [RoutineExerciseType: RoutineExerciseInfo] = [
    // Core Exercises
    .frontPlank: RoutineExerciseInfo(
        easy: 10,
        medium: 30,
        hard: 60,
        name: "Plank",
        benefit: .core,
        description: "The plank is a simple exercise that helps you build stability and strength throughout your entire body. It’s a great exercise for your core, and it also works your glutes, hamstrings, arms, shoulders, and back.",
        exerciseDescription: "Get into a pushup position, but bend your elbows and rest your weight on your forearms instead of on your hands. Your body should form a straight line from your shoulders to your ankles. Brace your core by contracting your abs as if you were about to be punched in the gut. Hold this position for the prescribed time.",
        amountType: .time,
        reference: "https://www.physio-pedia.com/Plank_exercise"
    ),
    .sidePlank: RoutineExerciseInfo(
        easy: 10,
        medium: 20,
        hard: 30,
        name: "Side Plank",
        benefit: .core,
        description: "The side plank is a great exercise for strengthening your oblique muscles and improving core stability.",
        exerciseDescription: "Lie on your side with your legs straight and prop your upper body up on your elbow. Raise your hips until your body forms a straight line from your ankles to your shoulders. Hold this position for the prescribed time, then switch sides.",
        amountType: .time,
        reference: "https://www.verywellfit.com/side-plank-2911322"
    ),
    .backPlank: RoutineExerciseInfo(
        easy: 10,
        medium: 20,
        hard: 30,
        name: "Back Plank",
        benefit: .core,
        description: "The back plank is a variation of the plank exercise that targets your lower back, glutes, and hamstrings while also engaging your core.",
        exerciseDescription: "Lie on your back with your arms by your sides, palms down. Lift your hips off the ground, creating a straight line from your shoulders to your feet. Engage your glutes and hold this position for the prescribed time.",
        amountType: .time,
        reference: "https://www.healthline.com/health/fitness/back-plank"
    ),
    .otherSidePlank: RoutineExerciseInfo(
        easy: 10,
        medium: 20,
        hard: 30,
        name: "Other Side Plank",
        benefit: .core,
        description: "This exercise is similar to the side plank but performed on the opposite side to target the other set of oblique muscles.",
        exerciseDescription: "Lie on your side with your legs straight and prop your upper body up on your elbow. Raise your hips until your body forms a straight line from your ankles to your shoulders. Hold this position for the prescribed time, then switch sides.",
        amountType: .time,
        reference: "https://www.verywellfit.com/side-plank-2911322"
    ),
    .gluteBridge: RoutineExerciseInfo(
        easy: 8,
        medium: 10,
        hard: 12,
        name: "Glute Bridge",
        benefit: .core,
        description: "The glute bridge primarily targets your glutes but also engages your core and lower back muscles.",
        exerciseDescription: "Lie on your back with your knees bent and feet flat on the ground. Lift your hips off the ground until your body forms a straight line from your shoulders to your knees. Squeeze your glutes at the top and lower your hips back down.",
        amountType: .count,
        reference: "https://www.verywellfit.com/glute-bridge-exercise-2911343"
    ),
    .superman: RoutineExerciseInfo(
        easy: 5,
        medium: 8,
        hard: 10,
        name: "Superman",
        benefit: .core,
        description: "The Superman exercise targets your lower back and glutes while also engaging your core and upper back.",
        exerciseDescription: "Lie face down with your arms extended in front of you and your legs straight. Lift your arms, chest, and legs off the ground, squeezing your glutes and lower back muscles. Hold this position briefly, then lower your limbs back down.",
        amountType: .count,
        reference: "https://www.verywellfit.com/superman-exercise-2911542"
    ),

    // Legs Exercises
    .forwardLunge: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Forward Lunge",
        benefit: .legs,
        description: "The forward lunge is an excellent exercise for targeting your quadriceps and glutes while improving balance and stability.",
        exerciseDescription: "Stand with your feet hip-width apart. Take a step forward with one leg and lower your body until both knees are bent at a 90-degree angle. Push back up to the starting position and repeat on the other leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/lunges-for-beginners-2911076"
    ),
    .forwardLungeWithTwist: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Forward Lunge with Twist",
        benefit: .legs,
        description: "This exercise adds a twist to the forward lunge, engaging your core and improving hip mobility.",
        exerciseDescription: "Perform a forward lunge as described above, but as you lunge forward, twist your torso to the same side as your forward leg. Return to the starting position and repeat on the other leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/lunges-for-beginners-2911076"
    ),
    .sideLunge: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Side Lunge",
        benefit: .legs,
        description: "The side lunge targets your inner and outer thighs, quadriceps, and glutes while also working on your balance and stability.",
        exerciseDescription: "Stand with your feet together. Take a step to the side with one leg and lower your body, keeping your other leg straight. Push back to the starting position and repeat on the other side.",
        amountType: .count,
        reference: "https://www.verywellfit.com/lateral-lunges-2911240"
    ),
    .backAndToTheSideLunge: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Back and to the Side Lunge",
        benefit: .legs,
        description: "This exercise combines backward and side lunges to target different muscle groups in your legs.",
        exerciseDescription: "Step back with one leg and perform a backward lunge. Return to the starting position and then step to the side with the same leg to perform a side lunge. Alternate between backward and side lunges on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/lateral-lunges-2911240"
    ),
    .backwardLunge: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Backward Lunge",
        benefit: .legs,
        description: "The backward lunge targets your quadriceps and glutes while working on balance and stability.",
        exerciseDescription: "Step back with one leg and perform a lunge by bending both knees to a 90-degree angle. Return to the starting position and repeat on the other leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/lunges-for-beginners-2911076"
    ),
    .squats: RoutineExerciseInfo(
        easy: 15,
        medium: 30,
        hard: 50,
        name: "Squats",
        benefit: .legs,
        description: "Squats are a great lower body exercise that target your quadriceps, hamstrings, and glutes. They also work your core and improve overall leg strength.",
        exerciseDescription: "Stand with your feet shoulder-width apart. Lower your body by bending your knees and pushing your hips back as if you're sitting in a chair. Keep your back straight and chest up. Go as low as you can while maintaining good form, and then push through your heels to stand back up.",
        amountType: .count,
        reference: "https://www.verywellfit.com/the-basic-squat-2911406"
    ),
    .squattingCalfRaisesIn90DegreeSquatPosition: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Squatting Calf Raises in 90-Degree Squat Position",
        benefit: .legs,
        description: "This exercise combines squats with calf raises, targeting your quadriceps, glutes, and calf muscles.",
        exerciseDescription: "Perform a squat by bending your knees to a 90-degree angle, then push up onto the balls of your feet to perform calf raises. Lower your heels and repeat the sequence.",
        amountType: .count,
        reference: "https://www.verywellfit.com/how-to-do-a-squat-calf-raise-2911485"
    ),
    .legRaiseTo90DegreesWithBentKnee: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Leg Raise to 90 Degrees with Bent Knee",
        benefit: .legs,
        description: "This exercise involves lifting your legs with bent knees to a 90-degree angle, targeting your lower abdominal muscles.",
        exerciseDescription: "Lie on your back with your legs straight. Lift your legs with bent knees until your thighs are perpendicular to the ground. Lower your legs back down without letting your feet touch the floor.",
        amountType: .count,
        reference: "https://www.verywellfit.com/double-leg-lower-lifts-2911354"
    ),
    .kneeCirclesForward: RoutineExerciseInfo(
        easy: 8,
        medium: 12,
        hard: 16,
        name: "Knee Circles Forward",
        benefit: .legs,
        description: "Knee circles forward help improve hip mobility and flexibility while working your leg muscles.",
        exerciseDescription: "Stand with your feet hip-width apart. Lift one knee and start making circular movements with your knee, moving it forward. Repeat the prescribed number of circles on each leg.",
        amountType: .count,
        reference: "https://www.wikihow.fitness/Exercise-Your-Hip-Muscles"
    ),
    .kneeCirclesBackward: RoutineExerciseInfo(
        easy: 8,
        medium: 12,
        hard: 16,
        name: "Knee Circles Backward",
        benefit: .legs,
        description: "Knee circles backward help improve hip mobility and flexibility while working your leg muscles.",
        exerciseDescription: "Stand with your feet hip-width apart. Lift one knee and start making circular movements with your knee, moving it backward. Repeat the prescribed number of circles on each leg.",
        amountType: .count,
        reference: "https://www.wikihow.fitness/Exercise-Your-Hip-Muscles"
    ),
    .lateralLegRaise: RoutineExerciseInfo(
        easy: 5,
        medium: 8,
        hard: 10,
        name: "Lateral Leg Raise",
        benefit: .legs,
        description: "The lateral leg raise targets your outer thighs and hips.",
        exerciseDescription: "Lie on your side with your legs straight. Lift your top leg as high as you can, keeping it straight. Lower your leg back down. Repeat the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/lateral-leg-lifts-2911057"
    ),
    .toeLungeWalk: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Toe Lunge Walk",
        benefit: .legs,
        description: "The toe lunge walk is a walking exercise that combines forward lunges with a toe walk.",
        exerciseDescription: "Take a step forward with one leg and perform a forward lunge. As you come back up, rise onto your toes and walk forward. Repeat the sequence for the prescribed distance.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/lunges-for-beginners-2911076"
    ),
    .wideOuts: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Wide Outs",
        benefit: .legs,
        description: "Wide outs are a plyometric exercise that targets your leg muscles.",
        exerciseDescription: "Start with your feet close together and your hands by your sides. Jump up and spread your feet wide apart while raising your arms out to the sides. Jump back to the starting position and repeat.",
        amountType: .count,
        reference: "https://www.verywellfit.com/plyometric-exercises-2910834"
    ),
    .waveLunge: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Wave Lunge",
        benefit: .legs,
        description: "Wave lunges are a variation of forward lunges that challenge your leg muscles and coordination.",
        exerciseDescription: "Perform forward lunges by stepping forward and then immediately stepping back, creating a 'wave' motion. Repeat the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/alternative-exercises-2911221"
    ),
    .mountainClimbersSinglesIn: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Mountain Climbers - Singles In",
        benefit: .legs,
        description: "Mountain climbers are a dynamic exercise that engages your leg muscles and core.",
        exerciseDescription: "Get into a push-up position. Bring one knee toward your chest, then quickly switch and bring the other knee in. Continue alternating legs, like you're climbing a mountain.",
        amountType: .count,
        reference: "https://www.verywellfit.com/mountain-climbers-2911109"
    ),
    .mountainClimbersSinglesOut: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Mountain Climbers - Singles Out",
        benefit: .legs,
        description: "Mountain climbers are a dynamic exercise that engages your leg muscles and core.",
        exerciseDescription: "Get into a push-up position. Bring one knee toward your chest, then quickly switch and bring the other knee out to the side. Continue alternating legs, like you're climbing a mountain.",
        amountType: .count,
        reference: "https://www.verywellfit.com/mountain-climbers-2911109"
    ),
    .mountainClimbersDoublesIn: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Mountain Climbers - Doubles In",
        benefit: .legs,
        description: "Mountain climbers are a dynamic exercise that engages your leg muscles and core.",
        exerciseDescription: "Get into a push-up position. Bring both knees toward your chest at the same time, then quickly switch and bring them back out. Continue this double-leg motion.",
        amountType: .count,
        reference: "https://www.verywellfit.com/mountain-climbers-2911109"
    ),
    .mountainClimbersDoublesOut: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Mountain Climbers - Doubles Out",
        benefit: .legs,
        description: "Mountain climbers are a dynamic exercise that engages your leg muscles and core.",
        exerciseDescription: "Get into a push-up position. Bring both knees out to the sides at the same time, then quickly switch and bring them back in. Continue this double-leg motion.",
        amountType: .count,
        reference: "https://www.verywellfit.com/mountain-climbers-2911109"
    ),
    .sideSlide: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Side Slide",
        benefit: .legs,
        description: "The side slide is a lateral movement exercise that targets your leg muscles and improves agility.",
        exerciseDescription: "Begin in a low squat position. Slide sideways to one side, keeping your feet close together. Repeat the motion for the prescribed distance, then switch directions.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/plyometric-exercises-2910834"
    ),
    .sideJumpJacks: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Side Jump Jacks",
        benefit: .legs,
        description: "Side jump jacks are a plyometric exercise that combines jumping jacks with lateral movements.",
        exerciseDescription: "Start with your feet together and arms by your sides. Jump up and spread your feet wide apart while raising your arms out to the sides. Jump back to the starting position and repeat.",
        amountType: .count,
        reference: "https://www.verywellfit.com/plyometric-exercises-2910834"
    ),

    // Core and Leg Combined
    .vSitFlutterKicks: RoutineExerciseInfo(
        easy: 15,
        medium: 20,
        hard: 25,
        name: "V-Sit Flutter Kicks",
        benefit: .coreAndLegs,
        description: "V-sit flutter kicks engage both your core and leg muscles, promoting strength and stability.",
        exerciseDescription: "Sit on the floor with your legs straight and your upper body leaning back slightly. Lift your legs a few inches off the ground and alternate kicking them up and down.",
        amountType: .count,
        reference: "https://www.verywellfit.com/v-sit-flutter-kicks-2911708"
    ),
    .sidePlankLegLift: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Side Plank Leg Lift",
        benefit: .coreAndLegs,
        description: "The side plank leg lift combines side planks with leg lifts to strengthen your core and hips.",
        exerciseDescription: "Get into a side plank position with your top hand on your hip. Lift your top leg as high as you can, then lower it back down. Repeat the prescribed number of repetitions on each side.",
        amountType: .count,
        reference: "https://www.verywellfit.com/side-plank-with-leg-lift-2911377"
    ),
    .backPlankLegLift: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Back Plank Leg Lift",
        benefit: .coreAndLegs,
        description: "The back plank leg lift combines back planks with leg lifts to target your core, glutes, and hamstrings.",
        exerciseDescription: "Lie on your back with your arms by your sides and palms down. Lift your hips and legs off the ground. Lift one leg as high as you can, then lower it back down. Repeat the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/back-leg-lifts-2911010"
    ),
    .pushUpToSidePlank: RoutineExerciseInfo(
        easy: 5,
        medium: 8,
        hard: 10,
        name: "Push-Up to Side Plank",
        benefit: .coreAndLegs,
        description: "This exercise combines push-ups with side planks, targeting your chest, triceps, core, and hip muscles.",
        exerciseDescription: "Start in a push-up position. Perform a push-up, then rotate into a side plank with one arm extended upward. Return to the push-up position and repeat on the other side.",
        amountType: .count,
        reference: "https://www.verywellfit.com/push-up-to-side-plank-2911278"
    ),
    .vSitScissorKick: RoutineExerciseInfo(
        easy: 15,
        medium: 20,
        hard: 25,
        name: "V-Sit Scissor Kick",
        benefit: .coreAndLegs,
        description: "The V-sit scissor kick works your core and leg muscles while enhancing flexibility and balance.",
        exerciseDescription: "Sit on the floor with your legs straight and your upper body leaning back slightly. Lift your legs a few inches off the ground and perform scissor-like movements by crossing one leg over the other.",
        amountType: .count,
        reference: "https://www.verywellfit.com/v-sit-flutter-kicks-2911708"
    ),

    // Glute and Leg Exercises
    .donkeyKicks: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Donkey Kicks",
        benefit: .glutesAndLegs,
        description: "Donkey kicks target your glutes and leg muscles, particularly the hamstrings and quadriceps.",
        exerciseDescription: "Start on your hands and knees. Lift one leg, keeping your knee bent at a 90-degree angle. Extend your leg upward, then lower it back down. Repeat the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/how-to-do-donkey-kicks-2911488"
    ),
    .donkeyWhips: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Donkey Whips",
        benefit: .glutesAndLegs,
        description: "Donkey whips are similar to donkey kicks but involve a whip-like motion to target the glutes and leg muscles.",
        exerciseDescription: "Start on your hands and knees. Lift one leg, keeping your knee bent at a 90-degree angle. Extend your leg upward, then quickly lower it and whip it back up. Repeat the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/how-to-do-donkey-whips-2911489"
    ),
    .fireHydrants: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Fire Hydrants",
        benefit: .glutesAndLegs,
        description: "Fire hydrants target your glutes and hip muscles, enhancing hip mobility and stability.",
        exerciseDescription: "Start on your hands and knees. Lift one leg to the side while keeping your knee bent at a 90-degree angle. Lower your leg back down and repeat the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/fire-hydrants-2911523"
    ),
    .reverseClams: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Reverse Clams",
        benefit: .glutesAndLegs,
        description: "Reverse clams target your glutes and hip muscles while enhancing hip stability and mobility.",
        exerciseDescription: "Lie on your side with your legs bent at a 90-degree angle. Keeping your feet together, lift your top knee as high as you can. Lower it back down and repeat the prescribed number of repetitions on each side.",
        amountType: .count,
        reference: "https://www.verywellfit.com/glute-exercises-2911110"
    ),
    .reverseAirClams: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Reverse Air Clams",
        benefit: .glutesAndLegs,
        description: "Reverse air clams are an advanced variation of reverse clams that further engage your glutes and hip muscles.",
        exerciseDescription: "Lie on your side with your legs straight. Keeping your feet together, lift your top leg as high as you can. Lower it back down and repeat the prescribed number of repetitions on each side.",
        amountType: .count,
        reference: "https://www.verywellfit.com/glute-exercises-2911110"
    ),
    .clams: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Clams",
        benefit: .glutesAndLegs,
        description: "Clams are a simple yet effective exercise for targeting your glutes and hip muscles.",
        exerciseDescription: "Lie on your side with your legs bent at a 90-degree angle. Keeping your feet together, lift your top knee as high as you can. Lower it back down and repeat the prescribed number of repetitions on each side.",
        amountType: .count,
        reference: "https://www.verywellfit.com/glute-exercises-2911110"
    ),

    // Mobility and Stretching
    .inchWormsWithPushUp: RoutineExerciseInfo(
        easy: 5,
        medium: 8,
        hard: 10,
        name: "Inch Worms with Push-Up",
        benefit: .mobilityAndStretching,
        description: "Inch worms with a push-up are a full-body exercise that also enhances flexibility and mobility.",
        exerciseDescription: "Start in a standing position. Bend at your waist and walk your hands out to a push-up position. Perform a push-up, then walk your hands back to your feet and stand up straight. Repeat the sequence.",
        amountType: .count,
        reference: "https://www.verywellfit.com/inchworm-exercise-2911083"
    ),
    .birdDogSideExtension: RoutineExerciseInfo(
        easy: 6,
        medium: 10,
        hard: 12,
        name: "Bird Dog Side Extension",
        benefit: .mobilityAndStretching,
        description: "The bird dog side extension targets your back, hips, and shoulders while enhancing balance and mobility.",
        exerciseDescription: "Start on your hands and knees. Extend one arm and the opposite leg straight out. Then, bend your elbow and knee, bringing them together under your body. Repeat the prescribed number of repetitions on each side.",
        amountType: .count,
        reference: "https://www.verywellfit.com/bird-dog-exercise-2911356"
    ),
    .bridgeWithHeelWalks: RoutineExerciseInfo(
        easy: 6,
        medium: 10,
        hard: 12,
        name: "Bridge with Heel Walks",
        benefit: .mobilityAndStretching,
        description: "The bridge with heel walks targets your glutes, hamstrings, and hip muscles while improving mobility and stability.",
        exerciseDescription: "Lie on your back with your knees bent and feet flat on the ground. Lift your hips off the ground and perform heel walks by sliding your feet back and forth. Lower your hips and repeat.",
        amountType: .count,
        reference: "https://www.verywellfit.com/bridge-exercise-2911264"
    ),
    .toeGrabPullForwardWithToesAndMoveForward: RoutineExerciseInfo(
        easy: 3,
        medium: 6,
        hard: 9,
        name: "Toe Grab, Pull Forward with Toes, and Move Forward",
        benefit: .mobilityAndStretching,
        description: "This exercise enhances flexibility and mobility in the toes and feet while promoting balance and stability.",
        exerciseDescription: "Sit down with your legs straight. Bend at the waist and try to grab your toes. Pull yourself forward using your toes, then release and repeat the sequence for the prescribed distance.",
        amountType: .distance,
        reference: "https://www.livestrong.com/article/487075-yoga-toes-exercise/"
    ),
    .toeWalk: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Toe Walk",
        benefit: .mobilityAndStretching,
        description: "Toe walking promotes mobility and flexibility in the feet while improving balance.",
        exerciseDescription: "Walk on your toes, taking small steps, for the prescribed distance. Maintain good posture and balance throughout the exercise.",
        amountType: .distance,
        reference: "https://www.livestrong.com/article/428722-toe-walking-ankle-flexibility/"
    ),
    .heelWalk: RoutineExerciseInfo(
        easy: 5,
        medium: 10,
        hard: 15,
        name: "Heel Walk",
        benefit: .mobilityAndStretching,
        description: "Heel walking promotes mobility in the ankles and calves while enhancing balance.",
        exerciseDescription: "Walk on your heels, taking small steps, for the prescribed distance. Maintain good posture and balance throughout the exercise.",
        amountType: .distance,
        reference: "https://www.livestrong.com/article/428722-toe-walking-ankle-flexibility/"
    ),
    .barefootInPlace: RoutineExerciseInfo(
        easy: 30,
        medium: 45,
        hard: 60,
        name: "Barefoot in Place",
        benefit: .mobilityAndStretching,
        description: "This exercise involves standing in place barefoot, helping to improve foot strength and balance.",
        exerciseDescription: "Simply stand in place, barefoot, for the prescribed time. You can shift your weight and roll your feet to promote flexibility and strength.",
        amountType: .time,
        reference: "https://www.healthline.com/health/exercises-for-healthy-feet"
    ),
    .straightLegSpellAlphabet: RoutineExerciseInfo(
        easy: 3,
        medium: 5,
        hard: 7,
        name: "Straight Leg Spell Alphabet",
        benefit: .mobilityAndStretching,
        description: "This exercise involves drawing the letters of the alphabet in the air with your toes to improve ankle mobility and flexibility.",
        exerciseDescription: "Sit down with your legs straight. Lift one leg and use your toes to 'write' the letters of the alphabet in the air. Repeat on the other leg.",
        amountType: .time,
        reference: "https://www.popsugar.com/fitness/photo-gallery/46421357/image/46421358/Sit-Up-Straight-Leg-Write-Alphabet"
    ),
    .outsideOfFootWalk: RoutineExerciseInfo(
        easy: 3,
        medium: 6,
        hard: 9,
        name: "Outside of Foot Walk",
        benefit: .mobilityAndStretching,
        description: "Walking on the outside of your feet promotes ankle mobility and balance.",
        exerciseDescription: "Walk by rolling your feet to the outside edges, taking small steps, for the prescribed distance. Maintain good posture and balance throughout the exercise.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/ankle-strengthening-exercises-2696620"
    ),
    .insideOfFootWalk: RoutineExerciseInfo(
        easy: 3,
        medium: 6,
        hard: 9,
        name: "Inside of Foot Walk",
        benefit: .mobilityAndStretching,
        description: "Walking on the inside of your feet promotes ankle mobility and balance.",
        exerciseDescription: "Walk by rolling your feet to the inside edges, taking small steps, for the prescribed distance. Maintain good posture and balance throughout the exercise.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/ankle-strengthening-exercises-2696620"
    ),
    .toesInWalk: RoutineExerciseInfo(
        easy: 3,
        medium: 6,
        hard: 9,
        name: "Toes In Walk",
        benefit: .mobilityAndStretching,
        description: "Walking with your toes pointed inward promotes ankle mobility and balance.",
        exerciseDescription: "Walk with your toes pointed inward, taking small steps, for the prescribed distance. Maintain good posture and balance throughout the exercise.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/ankle-strengthening-exercises-2696620"
    ),
    .toesOutWalk: RoutineExerciseInfo(
        easy: 3,
        medium: 6,
        hard: 9,
        name: "Toes Out Walk",
        benefit: .mobilityAndStretching,
        description: "Walking with your toes pointed outward promotes ankle mobility and balance.",
        exerciseDescription: "Walk with your toes pointed outward, taking small steps, for the prescribed distance. Maintain good posture and balance throughout the exercise.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/ankle-strengthening-exercises-2696620"
    ),

    // Walking Exercises
    .forwardWalk: RoutineExerciseInfo(
        easy: 100,
        medium: 200,
        hard: 300,
        name: "Forward Walk",
        benefit: .legs,
        description: "The forward walk is a simple yet effective walking exercise to improve cardiovascular health and leg strength.",
        exerciseDescription: "Walk forward at a moderate pace for the prescribed distance. Maintain good posture and a brisk walking pace.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/the-10-best-exercises-for-walking-3436516"
    ),
    .backwardWalk: RoutineExerciseInfo(
        easy: 100,
        medium: 200,
        hard: 300,
        name: "Backward Walk",
        benefit: .legs,
        description: "The backward walk is a unique walking exercise that challenges balance and coordination while working your leg muscles.",
        exerciseDescription: "Walk backward at a moderate pace for the prescribed distance. Keep your head up and maintain a brisk walking pace.",
        amountType: .distance,
        reference: "https://www.livestrong.com/article/493384-benefits-of-walking-backwards/"
    ),
    .singleLegHops: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Single Leg Hops",
        benefit: .legs,
        description: "Single leg hops improve leg strength and balance. They can be performed while standing or walking.",
        exerciseDescription: "Hop forward on one leg, landing softly. Repeat the prescribed number of hops on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/plyometric-exercises-2910834"
    ),
    .doubleLegHops: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Double Leg Hops",
        benefit: .legs,
        description: "Double leg hops are a plyometric exercise that enhances leg strength and power.",
        exerciseDescription: "Jump forward using both legs and land softly. Repeat the prescribed number of hops.",
        amountType: .count,
        reference: "https://www.verywellfit.com/plyometric-exercises-2910834"
    ),
    .forwardSkip: RoutineExerciseInfo(
        easy: 100,
        medium: 200,
        hard: 300,
        name: "Forward Skip",
        benefit: .legs,
        description: "Skipping is a fun and effective exercise for leg strength and cardiovascular fitness.",
        exerciseDescription: "Skip forward at a brisk pace for the prescribed distance. Alternate between your left and right legs for each skip.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/how-to-skip-2910829"
    ),
    .backwardSkip: RoutineExerciseInfo(
        easy: 100,
        medium: 200,
        hard: 300,
        name: "Backward Skip",
        benefit: .legs,
        description: "Skipping backward is a challenging exercise that enhances coordination and leg strength.",
        exerciseDescription: "Skip backward at a brisk pace for the prescribed distance. Alternate between your left and right legs for each skip.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/how-to-skip-2910829"
    ),
    .crouchedWalk: RoutineExerciseInfo(
        easy: 100,
        medium: 200,
        hard: 300,
        name: "Crouched Walk",
        benefit: .legs,
        description: "The crouched walk is a low, squatting walk that engages your leg muscles and improves mobility.",
        exerciseDescription: "Walk in a crouched position with your hips low, taking small steps. Maintain a steady pace and good form throughout the exercise.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/crouch-and-walk-2911698"
    ),

    // Upper Body Exercises
    .pushups: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Push-Ups",
        benefit: .upperBody,
        description: "Push-ups are a classic upper body exercise that work your chest, shoulders, and triceps.",
        exerciseDescription: "Assume a plank position with your hands shoulder-width apart. Lower your chest to the ground by bending your elbows, then push back up. Maintain a straight body throughout the exercise.",
        amountType: .count,
        reference: "https://www.verywellfit.com/how-to-do-a-push-up-2911282"
    ),
    .rockies: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Rockies",
        benefit: .upperBody,
        description: "Rockies are an upper body exercise that targets your chest, shoulders, and triceps while enhancing balance.",
        exerciseDescription: "Start in a push-up position. Lower your chest to the ground, then push up explosively and clap your hands under your chest. Land softly and repeat.",
        amountType: .count,
        reference: "https://www.verywellfit.com/push-up-exercise-2911544"
    ),
    .birdDog: RoutineExerciseInfo(
        easy: 6,
        medium: 10,
        hard: 12,
        name: "Bird Dog",
        benefit: .upperBody,
        description: "The bird dog exercise targets your back, shoulders, and core while enhancing balance and stability.",
        exerciseDescription: "Start on your hands and knees. Extend one arm and the opposite leg straight out. Hold for a moment, then lower and repeat on the other side.",
        amountType: .count,
        reference: "https://www.verywellfit.com/bird-dog-exercise-2911356"
    ),

    // Miscellaneous
    .runningVSits: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Running V-Sits",
        benefit: .coreAndLegs,
        description: "Running V-sits combine running in place with V-sit exercises to work your core and leg muscles.",
        exerciseDescription: "Sit on the ground with your legs straight and lean back slightly. Lift your legs and upper body off the ground and start 'running' in place with your legs while balancing on your sit bones.",
        amountType: .count,
        reference: "https://www.verywellfit.com/v-sit-exercise-2911360"
    ),
    .australianCrawl: RoutineExerciseInfo(
        easy: 20,
        medium: 40,
        hard: 60,
        name: "Australian Crawl",
        benefit: .upperBody,
        description: "The Australian crawl, or the 'freestyle' swimming style, is a full-body swimming exercise that enhances cardiovascular fitness and upper body strength.",
        exerciseDescription: "Swim freestyle, also known as the Australian crawl, for the prescribed distance. Focus on proper stroke and breathing techniques.",
        amountType: .distance,
        reference: "https://www.verywellfit.com/freestyle-stroke-technique-3160462"
    ),
    .groinSplitters: RoutineExerciseInfo(
        easy: 12,
        medium: 16,
        hard: 20,
        name: "Groin Splitters",
        benefit: .legs,
        description: "Groin splitters are an exercise that targets the inner thigh muscles and enhances hip mobility.",
        exerciseDescription: "Sit on the ground with your knees bent and the soles of your feet together. Press your knees down toward the ground and release. Repeat the motion for the prescribed number of repetitions.",
        amountType: .count,
        reference: "https://www.verywellfit.com/exercises-to-improve-hip-strength-3120418"
    ),

    // Level 3 Exercises
    .plankWithArmExtension: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Plank with Arm Extension",
        benefit: .core,
        description: "The plank with arm extension adds an arm lift to the traditional plank, intensifying core engagement.",
        exerciseDescription: "Get into a plank position with your forearms on the ground. Lift one arm off the ground and extend it forward. Hold for a moment, then switch arms. Maintain a strong plank position throughout.",
        amountType: .time,
        reference: "https://www.verywellfit.com/plank-with-arm-lift-2911164"
    ),
    .vSitAlternatingKneeBend: RoutineExerciseInfo(
        easy: 12,
        medium: 16,
        hard: 20,
        name: "V-Sit Alternating Knee Bend",
        benefit: .coreAndLegs,
        description: "The V-sit alternating knee bend is a challenging core and leg exercise that also enhances balance.",
        exerciseDescription: "Sit on the ground with your legs straight and your upper body leaning back slightly. Lift your legs a few inches off the ground. Bend one knee toward your chest while extending the other leg. Alternate legs for the prescribed number of repetitions.",
        amountType: .count,
        reference: "https://www.verywellfit.com/v-sit-knee-bend-2911402"
    ),
    .squatWithArmExtension: RoutineExerciseInfo(
        easy: 10,
        medium: 15,
        hard: 20,
        name: "Squat with Arm Extension",
        benefit: .legs,
        description: "The squat with arm extension combines squats with an arm lift to engage your leg muscles and upper body.",
        exerciseDescription: "Start in a standing position. Perform a squat, and as you stand back up, extend your arms overhead. Lower your arms and repeat for the prescribed number of repetitions.",
        amountType: .count,
        reference: "https://www.verywellfit.com/bodyweight-squat-2911385"
    ),
    .legExtensionsForwardAndBack: RoutineExerciseInfo(
        easy: 12,
        medium: 16,
        hard: 20,
        name: "Leg Extensions Forward and Back",
        benefit: .legs,
        description: "Leg extensions forward and back target your quadriceps and improve leg strength and stability.",
        exerciseDescription: "Stand on one leg and extend the other leg forward. Lower it back down, then extend it backward. Repeat the motion for the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/leg-extensions-2911760"
    ),
    .legExtensionsAt45DegreesForwardAndBack: RoutineExerciseInfo(
        easy: 12,
        medium: 16,
        hard: 20,
        name: "Leg Extensions at 45 Degrees Forward and Back",
        benefit: .legs,
        description: "Leg extensions at 45 degrees engage your quadriceps and improve leg strength and stability at a specific angle.",
        exerciseDescription: "Stand on one leg and extend the other leg forward at a 45-degree angle. Lower it back down, then extend it backward at the same angle. Repeat the motion for the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/leg-extensions-2911760"
    ),
    .kneeToChestExtension: RoutineExerciseInfo(
        easy: 12,
        medium: 16,
        hard: 20,
        name: "Knee to Chest Extension",
        benefit: .legs,
        description: "Knee to chest extensions work your hip and thigh muscles, enhancing flexibility and mobility.",
        exerciseDescription: "Stand on one leg and bring the opposite knee up to your chest. Extend your leg outward, then return it to the chest and extend it backward. Repeat the motion for the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/leg-extensions-2911760"
    ),
    .bentKneeLegExtension: RoutineExerciseInfo(
        easy: 12,
        medium: 16,
        hard: 20,
        name: "Bent Knee Leg Extension",
        benefit: .legs,
        description: "The bent knee leg extension exercise targets your quadriceps and enhances leg strength and stability.",
        exerciseDescription: "Stand on one leg and extend the opposite leg forward with a bent knee. Lower it back down, then extend it backward with the knee bent. Repeat the motion for the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/leg-extensions-2911760"
    ),
    .inAndOutLegExtensionWithBentKnee: RoutineExerciseInfo(
        easy: 12,
        medium: 16,
        hard: 20,
        name: "In and Out Leg Extension with Bent Knee",
        benefit: .legs,
        description: "The in and out leg extension with a bent knee engages your quadriceps and improves leg strength and stability.",
        exerciseDescription: "Stand on one leg and extend the opposite leg forward with a bent knee. Open your leg outward to the side, then return it to the center and extend it backward with the knee bent. Repeat the motion for the prescribed number of repetitions on each leg.",
        amountType: .count,
        reference: "https://www.verywellfit.com/leg-extensions-2911760"
    ),
    .yPullover: RoutineExerciseInfo(
        easy: 12,
        medium: 16,
        hard: 20,
        name: "Y Pullover",
        benefit: .upperBody,
        description: "The Y pullover targets your back, shoulders, and core while improving balance and mobility.",
        exerciseDescription: "Lie on your back with your legs straight and your arms extended overhead in a Y shape. Lift your legs and upper body off the ground while keeping your arms straight. Hold for a moment, then lower and repeat.",
        amountType: .count,
        reference: "https://www.verywellfit.com/exercises-for-strong-shoulders-2911687"
    ),
    .straightPullover: RoutineExerciseInfo(
        easy: 12,
        medium: 16,
        hard: 20,
        name: "Straight Pullover",
        benefit: .upperBody,
        description: "The straight pullover targets your back, shoulders, and core while improving balance and mobility.",
        exerciseDescription: "Lie on your back with your legs straight and your arms extended overhead. Lift your legs and upper body off the ground while keeping your arms straight. Hold for a moment, then lower and repeat.",
        amountType: .count,
        reference: "https://www.verywellfit.com/exercises-for-strong-shoulders-2911687"
    ),

    // Stretches
    .hamstringStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Hamstring Stretch",
        benefit: .stretching,
        description: "The hamstring stretch enhances flexibility in the hamstrings, which are the muscles on the back of your thighs.",
        exerciseDescription: "Sit with one leg extended straight and the other leg bent so that the sole of your foot is against your inner thigh. Reach forward and try to touch your toes, keeping your back straight.",
        amountType: .time,
        reference: "https://www.verywellfit.com/hamstring-stretch-2696550"
    ),
    .quadricepsStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Quadriceps Stretch",
        benefit: .stretching,
        description: "The quadriceps stretch targets the front thigh muscles and improves leg flexibility.",
        exerciseDescription: "Stand or sit, then grab one ankle behind you and gently pull it upward toward your buttocks. Keep your knees close together and maintain an upright posture.",
        amountType: .time,
        reference: "https://www.verywellfit.com/how-to-do-the-quadriceps-stretch-2911217"
    ),
    .calfStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Calf Stretch",
        benefit: .stretching,
        description: "The calf stretch enhances flexibility in the calf muscles, which are located in the lower legs.",
        exerciseDescription: "Stand facing a wall with your hands against it. Step one foot back and press your heel into the ground. Keep your back leg straight and bend your front knee to feel the stretch in your calf.",
        amountType: .time,
        reference: "https://www.verywellfit.com/calf-stretches-2911021"
    ),
    .hipFlexorStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Hip Flexor Stretch",
        benefit: .stretching,
        description: "The hip flexor stretch targets the muscles at the front of the hips and helps improve hip mobility.",
        exerciseDescription: "Kneel on one knee and step your other foot forward. Tuck your pelvis under and lean your body forward to feel the stretch in the front of your hip.",
        amountType: .time,
        reference: "https://www.verywellfit.com/hip-flexor-stretch-2696369"
    ),
    .butterflyStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Butterfly Stretch",
        benefit: .stretching,
        description: "The butterfly stretch targets the inner thigh muscles and improves hip mobility.",
        exerciseDescription: "Sit with the soles of your feet together and your knees bent outward. Hold your feet and gently press your knees toward the ground to feel the stretch in your inner thighs.",
        amountType: .time,
        reference: "https://www.verywellfit.com/butterfly-stretch-2696356"
    ),
    .groinStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Groin Stretch",
        benefit: .stretching,
        description: "The groin stretch targets the inner thigh muscles and enhances hip mobility.",
        exerciseDescription: "Sit with your legs extended to the sides as far as possible. Gently lean forward to feel the stretch in your groin and inner thighs.",
        amountType: .time,
        reference: "https://www.verywellfit.com/groin-stretch-2696353"
    ),
    .lowerBackStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Lower Back Stretch",
        benefit: .stretching,
        description: "The lower back stretch helps alleviate tension in the lower back muscles and improves flexibility.",
        exerciseDescription: "Sit with your legs extended straight. Cross one leg over the other and hug your knee to your chest. Twist your torso gently to the side to feel the stretch in your lower back.",
        amountType: .time,
        reference: "https://www.verywellfit.com/lower-back-stretches-2696357"
    ),
    .tricepsStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Triceps Stretch",
        benefit: .stretching,
        description: "The triceps stretch targets the back of the upper arms and enhances arm flexibility.",
        exerciseDescription: "Raise one arm overhead, bending your elbow. Use your opposite hand to gently push on your bent elbow, feeling the stretch in your triceps.",
        amountType: .time,
        reference: "https://www.verywellfit.com/tricep-stretch-2696360"
    ),
    .shoulderStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Shoulder Stretch",
        benefit: .stretching,
        description: "The shoulder stretch targets the shoulder muscles and improves shoulder flexibility.",
        exerciseDescription: "Extend one arm across your body at chest height. Use your opposite hand to gently press on your upper arm, feeling the stretch in your shoulder.",
        amountType: .time,
        reference: "https://www.verywellfit.com/shoulder-stretches-2911117"
    ),
    .neckStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Neck Stretch",
        benefit: .stretching,
        description: "The neck stretch helps alleviate tension in the neck muscles and improves neck flexibility.",
        exerciseDescription: "Sit or stand with your back straight. Gently tilt your head to one side, bringing your ear toward your shoulder. Hold the stretch, then repeat on the other side.",
        amountType: .time,
        reference: "https://www.verywellfit.com/neck-stretches-2911092"
    ),
    .chestStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Chest Stretch",
        benefit: .stretching,
        description: "The chest stretch targets the chest muscles and enhances chest flexibility.",
        exerciseDescription: "Stand with your feet shoulder-width apart. Clasp your hands behind your back and straighten your arms, pulling your shoulders back and opening your chest.",
        amountType: .time,
        reference: "https://www.verywellfit.com/chest-stretches-2911548"
    ),
    .backStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Back Stretch",
        benefit: .stretching,
        description: "The back stretch targets the back muscles and helps improve back flexibility.",
        exerciseDescription: "Sit on the ground with your legs straight. Reach your arms forward, bending at your waist to touch your toes or the ground, feeling the stretch in your back.",
        amountType: .time,
        reference: "https://www.verywellfit.com/hamstring-stretch-2696550"
    ),
    .sideStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Side Stretch",
        benefit: .stretching,
        description: "The side stretch targets the muscles along your side and enhances overall flexibility.",
        exerciseDescription: "Stand with your feet shoulder-width apart. Raise one arm overhead and lean your body to the opposite side, feeling the stretch along your torso. Hold the stretch, then repeat on the other side.",
        amountType: .time,
        reference: "https://www.verywellfit.com/side-stretch-2911161"
    ),
    .wristFlexorStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Wrist Flexor Stretch",
        benefit: .stretching,
        description: "The wrist flexor stretch targets the muscles on the underside of your forearm and improves wrist flexibility.",
        exerciseDescription: "Extend one arm forward with your palm facing up. Use your opposite hand to gently bend your wrist, pulling your fingers toward you. Feel the stretch on the underside of your forearm.",
        amountType: .time,
        reference: "https://www.verywellfit.com/forearm-stretches-2911125"
    ),
    .wristExtensorStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Wrist Extensor Stretch",
        benefit: .stretching,
        description: "The wrist extensor stretch targets the muscles on the top of your forearm and improves wrist flexibility.",
        exerciseDescription: "Extend one arm forward with your palm facing down. Use your opposite hand to gently bend your wrist, pulling your fingers downward. Feel the stretch on the top of your forearm.",
        amountType: .time,
        reference: "https://www.verywellfit.com/forearm-stretches-2911125"
    ),
    .ankleStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Ankle Stretch",
        benefit: .stretching,
        description: "The ankle stretch targets the muscles around your ankle joint and improves ankle flexibility and mobility.",
        exerciseDescription: "Sit on the ground with one leg extended straight. Cross your other leg over the extended one and gently pull your toes back toward your shin to feel the stretch in your ankle.",
        amountType: .time,
        reference: "https://www.verywellfit.com/ankle-stretches-2696435"
    ),
    .innerThighStretch: RoutineExerciseInfo(
        easy: 20,
        medium: 30,
        hard: 40,
        name: "Inner Thigh Stretch",
        benefit: .stretching,
        description: "The inner thigh stretch targets the inner thigh muscles and enhances leg flexibility.",
        exerciseDescription: "Sit on the ground with your knees bent and the soles of your feet together. Gently press your knees toward the ground to feel the stretch in your inner thighs.",
        amountType: .time,
        reference: "https://www.verywellfit.com/groin-stretch-2696353"
    ),
]
