import Foundation
import SwiftUI

public let postRunExerciseReference: [PostRunExerciseType: PostRunExerciseInfo] = [
    .plank: PostRunExerciseInfo(
        easy: .time(10),
        medium: .time(10),
        hard: .time(30),
        name: "Plank",
        benefit: .core,
        description: "https://www.physio-pedia.com/Plank_exercise",
        exerciseDescription: "Get into a pushup position, but bend your elbows and rest your weight on your forearms instead of on your hands. Your body should form a straight line from your shoulders to your ankles. Brace your core by contracting your abs as if you were about to be punched in the gut. Hold this position for the prescribed time.",
        icon: Image(systemName: "figure.walk"),
        reference: "https://www.physio-pedia.com/Plank_exercise"
    ),
    .pushup: PostRunExerciseInfo(
        easy: .count(10),
        medium: .count(20),
        hard: .count(30),
        name: "Pushup",
        benefit: .arms,
        description: "https://www.acefitness.org/resources/everyone/exercise-library/",
        exerciseDescription: "Get into a pushup position, but bend your elbows and rest your weight on your forearms instead of on your hands. Your body should form a straight line from your shoulders to your ankles. Brace your core by contracting your abs as if you were about to be punched in the gut. Hold this position for the prescribed time.",
        icon: Image(systemName: "figure.walk"),
        reference: "https://www.physio-pedia.com/Plank_exercise"
    ),
    .squat: PostRunExerciseInfo(
        easy: .count(10),
        medium: .count(20),
        hard: .count(30),
        name: "Squat",
        benefit: .legs,
        description: "Squats are a great way to build lower body strength and endurance. They are also a great way to build endurance in both the abs and back, as well as the stabilizer muscles.",
        exerciseDescription: "Get into a pushup position, but bend your elbows and rest your weight on your forearms instead of on your hands. Your body should form a straight line from your shoulders to your ankles. Brace your core by contracting your abs as if you were about to be punched in the gut. Hold this position for the prescribed time.",
        icon: Image(systemName: "figure.walk"),
        reference: "https://www.physio-pedia.com/Plank_exercise"
    ),
    .lunge: PostRunExerciseInfo(
        easy: .count(10),
        medium: .count(20),
        hard: .count(30),
        name: "Squat",
        benefit: .legs,
        description: "Squats are a great way to build lower body strength and endurance. They are also a great way to build endurance in both the abs and back, as well as the stabilizer muscles.",
        exerciseDescription: "Get into a pushup position, but bend your elbows and rest your weight on your forearms instead of on your hands. Your body should form a straight line from your shoulders to your ankles. Brace your core by contracting your abs as if you were about to be punched in the gut. Hold this position for the prescribed time.",
        icon: Image(systemName: "figure.walk"),
        reference: "https://www.physio-pedia.com/Plank_exercise"
    ),
]
