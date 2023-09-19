import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUICalendar

public enum TrainingUtils {
    public static func processUploadedActivity(_ activity: ActivityDataWithRoute) {
        print("Processing uploaded activity")

        let summaryData = DailySummaryData(distance: activity.distance, duration: activity.duration, activities: [activity.uid])
    }

    public static func getTrainingMonthData(_ date: YearMonth) async -> MonthlyTrainingData {
        do {
            let monthDocument = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("training").document("\(date.year)-\(date.month)").getDocument(as: MonthlyTrainingDataDocument.self)

            return MonthlyTrainingData(
                totalDistance: monthDocument.totalDistance,
                totalDuration: monthDocument.totalDuration,
                days: monthDocument.days.mapValues { dayDocument in
                    DailyTrainingData(
                        date: dayDocument.date.toYearMonthDay(),
                        type: dayDocument.type,
                        goals: dayDocument.goals,
                        summary: dayDocument.summary
                    )
                },
                weeklySummaries: monthDocument.weeklySummaries
            )
        } catch {
            Global.log.error("Error getting training month data: \(error)")
        }
        return MonthlyTrainingData(totalDistance: 0, totalDuration: 0, days: [:], weeklySummaries: [])
    }
}
