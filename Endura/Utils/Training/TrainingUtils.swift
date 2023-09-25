import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUICalendar

public enum TrainingUtils {
    public static func saveTrainingMonthData(_ data: MonthlyTrainingData) {
        do {
            try Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("training")
                .document("\(data.date.year)-\(data.date.month)").setData(from: MonthlyTrainingDataDocument(data))
        } catch {
            Global.log.error("Error saving training month data: \(error)")
        }
    }

    public static func getTrainingMonthData(_ date: YearMonth) async -> MonthlyTrainingData? {
        do {
            let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID())
                .collection("training").document("\(date.year)-\(date.month)").getDocument()
            if !document.exists {
                return nil
            }

            let monthDocument = try document.data(as: MonthlyTrainingDataDocument.self)

            var dailyTrainingData: [YearMonthDay: DailyTrainingData] = [:]
            for (day, dailyData) in monthDocument.days {
                dailyTrainingData[YearMonthDay.fromCache(day)] = DailyTrainingData(
                    date: YearMonthDay.fromCache(day),
                    type: dailyData.type,
                    goals: dailyData.goals,
                    summary: dailyData.summary ?? DailySummaryData(distance: 0, duration: 0, activities: 0)
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
        return nil
    }
}
