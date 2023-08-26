import Foundation

public final class ActivityViewModel: ObservableObject {
    @Published var analysisPosition: Date? = nil
    @Published var analysisValue: Double? = nil

    private let activityData: IndexedGraphData
    private let routeLocationData: IndexedRouteLocationData

    init(activityData: IndexedGraphData, routeLocationData: IndexedRouteLocationData) {
        self.activityData = activityData
        self.routeLocationData = routeLocationData
    }

    public func getAnalysisValue(for position: Date) -> GraphData? {
        let position = position.roundedToNearestSecond()
        return activityData[position]
            ?? activityData[position.addingTimeInterval(-1)]
            ?? activityData[position.addingTimeInterval(1)]
    }

    public func getAnalysisLocation(for position: Date) -> LocationData? {
        return routeLocationData[position.roundedToNearestSecond()]
    }

    @Published var workoutDuration: TimeInterval? = nil
    @Published var workoutStartDate: Date? = nil
    @Published var workoutEndDate: Date? = nil
}
