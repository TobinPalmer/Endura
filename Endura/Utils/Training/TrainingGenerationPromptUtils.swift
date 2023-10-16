import Foundation
import SwiftUICalendar

public enum TrainingGenerationPromptUtils {
    private static let generalDailyRules =
        """
            - Each week should typically have at least 1 long run, 1 workout, and 1 rest day.
            - Rest days should only every be after long runs or workouts but do not have to be after both.
            - No rest days should be after easy or medium runs.
            - Workouts and long runs should never be back to back.
            - Overall schedule should align rest days to be on the athletes unavailable days.
            - Fewer rest days are better if the athlete can handle it.
            - Try to only have as many rest days as unavailable days.
        """

    private static let generalWorkoutRules =
        """
            - Easy and medium days can be more distance than the goal distance but the pace should always be slower.
            - They should never run their goal pace besides workouts.
             - Tempo runs should not be goal pace but 30 seconds slower than goal pace.
             - Long runs should never be more than 1.5x the goal distance.
             - Easy runs should be 1-2 minutes slower than goal pace.
             - Medium runs should be 30 seconds to 1 minute slower than goal pace.
             - Workouts should be at goal pace or faster.
             - Workouts should be 1-2 miles shorter than the goal distance.
        """

    private static let formattingRules =
        """
        For the output format every [type](description?) means that the full []() should be replaced with a value that fits the optional description and is the right type.
        """

    public static func basicContext(athleteInfo: String, goal: String, settings: String) -> String {
        """
            You are a training ai that is dedicated to help the running athlete reach their goals.
            Using the given info you must generate a training plan that will get them ideally to succeed with their goal by the date specified.

            Athlete info:
            \(athleteInfo)

            Goal info:
            \(goal)

            Training info:
            \(settings)
        """
    }

    public static func outputContextForDayTypes() -> String {
        """

        Training Rules:
        \(generalDailyRules)

        Formatting Rules:
        \(formattingRules)


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

    public static func promptForDailyTrainingData(_ days: String) -> String {
        """
        For these all of these days: \(days) return a raw json that follows this format (note: \(formattingRules)):
        {
          "[yyyy-mm-dd]": {
            "date": "[yyyy-mm-dd](same as day)",
            "type": "[enum: [Rest, Easy, Medium, Workout, Long]](the type of day this is, no goals needed for rest days)",
            "goals": [
              {
                "date": "[yyyy-mm-dd](same as day)",
                "type": "[enum: [None, Easy, Medium, Long, Workout]]",
                "workout": {
                  "[enumValue: workout]": {[enumValue: workout](see below for workout enum values)}
                },
                "description": "[string](short 1-2 sentence description of run and purpose)"
              }
            ]
          }
        }

        For enum value of workout, it should match the format of only one of the following:
          "open": {},
          "distance": {
            "distance": "[number](miles)"
          },
          "time": {
            "time": "[number](seconds)"
          },
          "pacer": {
            "distance": "[number](miles)",
            "time": "[number](seconds to complete distance)"
          }
        The enumValue for example would in the end look like this:
        "workout": {
            "distance": {
                "distance": 5
            }
        }

        Output should be { "[yyyy-mm-dd]": { ... } } for each day in \(days) as a raw json ONLY, no extra text.
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

    public static func getDaysInWeeksBetween(_ startDate: YearMonthDay, _ endDate: YearMonthDay) -> [String] {
        let daysBetween = Calendar.current.dateComponents([.day], from: startDate.getDate(), to: endDate.getDate()).day!
        let days = (0 ... daysBetween).map { day in
            Calendar.current.date(byAdding: .day, value: day, to: startDate.getDate())!.toYearMonthDay().toCache()
        }
        return days.chunked(into: 7).map { days in
            "\(days)"
        }
    }
}
