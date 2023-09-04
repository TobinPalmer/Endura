import Foundation
import SwiftUI

struct TrainingGoalList: View {
    var body: some View {
        VStack {
            ForEach(0 ..< 3) { _ in
                TrainingGoal()
            }
        }
    }
}
