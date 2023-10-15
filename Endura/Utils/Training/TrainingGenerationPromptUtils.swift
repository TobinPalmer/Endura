import Foundation
import SwiftUICalendar

public enum TrainingGenerationPromptUtils {
    private static let generalRules =
        """
        - Each week should typically have at least 1 long run, 1 workout, and 1 rest day.
            - Easy and medium days can be more distance than the goal distance but the pace should always be slower.
            - Rest days should only every be after long runs or workouts but do not have to be after both.
            - No rest days should be after easy or medium runs.
            - Workouts and long runs should never be back to back.
            - Overall schedule should align rest days to be on the athletes unavailable days.
            - Fewer rest days are better if the athlete can handle it.
            - Try to only have as many rest days as unavailable days.
            - They should never run their goal pace besides workouts.
            - Tempo runs should not be goal pace but 30 seconds slower than goal pace.
            - Long runs should never be more than 1.5x the goal distance.
            - Easy runs should be 1-2 minutes slower than goal pace.
            - Medium runs should be 30 seconds to 1 minute slower than goal pace.
            - Workouts should be at goal pace or faster.
            - Workouts should be 1-2 miles shorter than the goal distance.
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

            General Training Rules:
            \(generalRules)
        """
    }

    public static func outputContextForDayTypes() -> String {
        """

        For the example format of ouput, every [type](description?) means that the full []() should be replaced with a value that fits the optional description and is the right type.

        Training day types: [easy, medium, workout, long, rest]

        Give the training day type for each [yyyy-mm-dd] inputted as the below format.

        ```json
        [
          {
            "date": "[yyyy-mm-dd]",
            "type": "[string](training day type)"
          }
        ]
        ```

        Output (do not include `json...`, just have it be {}, and DO NOT give anything extra. ONLY THE RAW JSON SHOULD BE IN THE RESPONSE):
        """
    }

    public static func getDaysBetween(_ startDate: YearMonthDay, _ endDate: YearMonthDay) -> [YearMonthDay] {
        let daysBetween = Calendar.current.dateComponents([.day], from: startDate.getDate(), to: endDate.getDate()).day!
        let days = (0 ... daysBetween).map { day in
            Calendar.current.date(byAdding: .day, value: day, to: startDate.getDate())!
        }
        return days.map {
            $0.toYearMonthDay()
        }
    }
}
