import Foundation

public final class ActivityViewModel: ObservableObject {
    @Published var analysisPosition: Date? = nil
    @Published var analysisValue: Double? = nil

    @Published var lastTimestamp: Date? = nil

    private let activityData: IndexedGraphData
    private let routeLocationData: IndexedRouteLocationData
    public final let interval: Int

    init(activityData: IndexedGraphData, routeLocationData: IndexedRouteLocationData, interval: Int) {
        self.activityData = activityData
        self.routeLocationData = routeLocationData
        self.interval = interval
    }

    public func getAnalysisValue(for position: Date, graph: IndexedLineGraphData) -> Double? {
        let position = position.roundedToNearestSecond()
        var value = graph[position]
        // Get closest value using the interval because the graph is not always 1 second intervals and for longer runs then searching for closest value is needed
        if interval > 1 {
            for i in 1 ... interval / 2 {
                if value == nil {
                    value = graph[position.addingTimeInterval(-1 * Double(i))] ?? graph[position.addingTimeInterval(Double(i))]
                } else {
                    break
                }
            }
        }

        return value
    }

    public func getAnalysisLocation(for position: Date) -> LocationData? {
        routeLocationData[position.roundedToNearestSecond()]
    }

    @Published var workoutDuration: TimeInterval? = nil
    @Published var workoutStartDate: Date? = nil
    @Published var workoutEndDate: Date? = nil
}
