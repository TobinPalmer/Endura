import Foundation
import SwiftUI

struct TrainingGoal: View {
    var body: some View {
        if Bool.random() {
            HStack {
                Image(systemName: "figure.run")
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text("Long Run")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(Int.random(in: 3 ..< 8)) miles")
                }
            }
        } else {
            HStack {
                Image(systemName: "figure.cooldown")
                    .font(.title)
                VStack(alignment: .leading) {
                    Text("Easy Post Run")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(Int.random(in: 10 ..< 30)) minutes")
                }
            }
        }
    }
}
