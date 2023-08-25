import Foundation

public final class ActivityViewModel: ObservableObject {
    @Published var analysisPosition: Date? = nil
    @Published var analysisValue: Double? = nil

    @Published var workoutDuration: TimeInterval? = nil
    @Published var workoutStartDate: Date? = nil
    @Published var workoutEndDate: Date? = nil
}
