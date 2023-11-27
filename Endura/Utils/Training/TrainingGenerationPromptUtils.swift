import Foundation
import SwiftUICalendar

public enum TrainingGenerationPromptUtils {
    private static let generalDailyRules =
        """
            - Each week should typically have at least 1 long run, 1 workout, and 1 rest day.
            - ONLY 1 rest day a week, and it should be on the day they are unavailable.
            - Rest days should only every be after long runs or workouts but do not have to be after both.
            - No rest days should be after easy or medium runs.
            - Workouts and long runs should never be back to back.
        """

    private static let generalWorkoutRules =
        """
            - Easy and medium days can be more distance than the goal distance but the pace should always be slower.
            - Long runs should never be more than 2.5x the goal distance.
            - Easy runs should be easy pace.
            - Medium runs should be medium pace.
            - Workouts should be at goal pace or slightly faster.
            - Workouts should be 1-2 miles shorter than the goal distance.
        """

    private static let formattingRules =
        """
        For the output format every [type](description?) means that the full []() should be replaced with a value that fits the optional description and is the right type.
        """

    public static func basicContextForEndGoal(athleteInfo: String, goal: String, trainingInfo: String) -> String {
        """
            You are a training ai that is dedicated to help the running athlete reach their goals.
            Using the given info you must generate a training plan that will get them ideally to succeed with their goal by the date specified.

            Athlete info:
            \(athleteInfo)

            Goal info:
            \(goal)

            Training info:
            (The start of the week is monday, so 0 is monday and 6 is sunday, the athlete is unavailable on the days specified as false)
            \(trainingInfo)
        """
    }

    public static func basicContextForCustom(athleteInfo: String, infoText: String, trainingInfo: String) -> String {
        """
            You are a training ai that is dedicated to help the running athlete reach their goals.
            Using the given info you must generate a training plan that will get them ideally to succeed with their goal by the date specified.

            Athlete info:
            \(athleteInfo)

            Goal Info (this is the athletes words on what they want their training to be like):
            "\(infoText)"

            Training info:
            (The start of the week is monday, so 0 is monday and 6 is sunday, the athlete is unavailable on the days specified as false)
            \(trainingInfo)
        """
    }

    public static func outputContextForDayTypes() -> String {
        """

        Training Rules:
        \(generalDailyRules)

        Formatting Rules:
        \(formattingRules)

        ONLY 1 rest day per week, make it the last day of the week.

        Give the training day type for each [yyyy-mm-dd] inputted as the below format.

        Training day types: [easy, medium, workout, long, rest]

        [
          {
            "date": "[yyyy-mm-dd]",
            "type": "[string](training day type)"
          }
        ]

        THE OUTPUT SHOULD BE ONLY THE RAW JSON FOR THE [yyyy-mm-dd] INPUTTED.

        [
            ...
        ]
        """
    }

    public static func contextForDailyTrainingData() -> String {
        """
        Training Rules:
        \(generalDailyRules)

        Training Workout Rules:
        \(generalWorkoutRules)
        """
    }

    public static func promptForDailyTrainingData(_ days: String, extraReference: String) -> String {
        """
        Important Extra Reference:
        \(extraReference)

        The last day should be a rest day.

        For these all of these days: \(days) return a raw json that follows this format (note: \(formattingRules)):
        {
          "[yyyy-mm-dd]": {
            "date": "[yyyy-mm-dd](same as day)",
            "type": "[enum: [Rest, Easy, Medium, Workout, Long]](the type of day this is, no goals needed for rest days, only one rest day a week)",
            "goals": [
              {
                "date": "[yyyy-mm-dd](same as day)",
                "type": "[enum: [None, Easy, Medium, Long, Workout]]",
                "workout": {
                    "pacer": {
                        "distance": "[number](miles)",
                        "time": "[number](matching training day pace with some variation * distance)"
                    }
                },
                "description": "[string](short 1-2 sentence description of run and purpose)"
              }
            ]
          }
        }

        Output should be { "[yyyy-mm-dd]": { ... } } for each day in \(days) as a raw json ONLY, no extra text.
        """
    }

    public static func promptForRoutinePlan(_ routineType: RoutineType, athleteInfo: String,
                                            lastRunInfo: String) -> String
    {
        """
        You are a training ai that is dedicated to help the running athlete recover from a run and improve their strength.
        Using the given info you must generate a routine plan that best helps them

        The plan type is \(routineType.rawValue)
        The routine should be about 10-15 minutes long, min: 10 exercises, max: 20 exercises
        It should be a variety of related exercises but barely any stretching
        For distances they should be in meters and all about the same, about 10 meters as a min

        Athlete info:
        \(athleteInfo)

        Run Just Completed:
        \(lastRunInfo)

        Reference structs for json output
        ```swift
        public enum RoutineType: String, Codable {
            case warmup = "Warm Up"
            case postRun = "Post Run"
        }

        public enum RoutineExerciseAmountType: String, Hashable, Codable {
            case time = "Seconds"
            case count = "Repetitions"
            case distance = "Meters"
        }

        public struct RoutineExercise: Hashable, Codable {
            public var type: RoutineExerciseType
            public var amount: Int
        }

        public struct RoutineData: Codable {
            public var type: RoutineType
            public var description: String
            public var exercises: [RoutineExercise]
        }
        ```

        Description should be about the purpose and goals of the routine.

        The PostRunExerciseType options are:
        \(RoutineExerciseType.allCases.map {
            $0.rawValue
        }
        .joined(separator: "\n"))

        Important:
        ALL enums should be the raw value of the enum, not the name of the enum. Ex: "Post Run" not "postRun"
        For parameter it should be:
        ```
            "parameter": {
                "time": {
                    "time": "[number](seconds)"
                }
            }
        ```

        For type it should be either "Post Run" or "Warm Up"

        Give RoutineData in a parsable json format:
        """
    }

    public static func outputExamplesForDayTypes() -> [(String, String)] {
        [(
            """
            ["2021-08-01", "2021-08-02", "2021-08-03", "2021-08-04", "2021-08-05", "2021-08-06", "2021-08-07"]
            """,
            """
            [
              {
                "date": "2021-08-01",
                "type": "easy"
              },
              {
                "date": "2021-08-02",
                "type": "medium"
              },
              {
                "date": "2021-08-03",
                "type": "easy"
              },
              {
                "date": "2021-08-04",
                "type": "workout"
              },
              {
                "date": "2021-08-05",
                "type": "easy"
              },
              {
                "date": "2021-08-06",
                "type": "long"
              },
              {
                "date": "2021-08-07",
                "type": "rest"
              }
            ]
            """
        )]
    }

    public static func getDaysInWeeksBetween(_ startDate: YearMonthDay, _ endDate: YearMonthDay) -> [[YearMonthDay]] {
        let daysBetween = Calendar.current.dateComponents([.day], from: startDate.getDate(), to: endDate.getDate()).day!
        let days = (0 ... daysBetween).map { day in
            Calendar.current.date(byAdding: .day, value: day, to: startDate.getDate())!.toYearMonthDay()
        }
        return days.chunked(into: 7)
    }
}
