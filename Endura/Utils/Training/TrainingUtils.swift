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

            var dailyTrainingData: [YearMonthDay: DailyTrainingData] = [:]
            for (day, dailyData) in monthDocument.days {
                dailyTrainingData[YearMonthDay.fromCache(day)] = DailyTrainingData(
                    date: YearMonthDay.fromCache(day),
                    type: dailyData.type,
                    goals: dailyData.goals,
                    summary: dailyData.summary
                )
            }

            return MonthlyTrainingData(
                date: date,
                totalDistance: monthDocument.totalDistance,
                totalDuration: monthDocument.totalDuration,
                days: dailyTrainingData
            )
        } catch {
            Global.log.error("Error getting training month data: \(error)")
        }
        return MonthlyTrainingData(date: date, totalDistance: 0, totalDuration: 0, days: [:])
    }
}
