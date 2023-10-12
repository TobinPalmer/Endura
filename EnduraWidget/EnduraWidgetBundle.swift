import SwiftUI
import WidgetKit

@main
struct EnduraWidgetBundle: WidgetBundle {
    var body: some Widget {
        EnduraWeeklyDistanceWidget()
        EnduraUpcomingGoalsWidget()
    }
}
