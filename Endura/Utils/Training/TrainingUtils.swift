import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUICalendar

public enum TrainingUtils {
    private static func getDailyTrainingReference(_ day: YearMonthDay) -> DocumentReference {
        Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("training").document("\(day.year)-\(day.month)")
    }

    public static func processUploadedActivity(_ activity: ActivityDataWithRoute) {
        print("Processing uploaded activity")

        let summaryData = DailySummaryData(distance: activity.distance, duration: activity.duration, activities: [activity.uid])

        let dayDocument = getDailyTrainingReference(activity.time.toYearMonthDay())
    }
}
