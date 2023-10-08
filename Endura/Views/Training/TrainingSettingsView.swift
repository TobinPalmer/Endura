import Foundation
import SwiftUI

struct TrainingSettingsView: View {
    @EnvironmentObject var activeUser: ActiveUserModel

    var body: some View {
        List {
            Section(header: Text("Day Availabilities")) {
                ForEach(0 ..< 7) { day in
                    HStack {
                        Toggle("\(WeekDay(rawValue: day)!.getShortName())", isOn: Binding(
                            get: {
                                activeUser.settings.data.training.dayAvailabilities[day] ?? true
                            },
                            set: { newValue in
                                activeUser.settings.data.training.dayAvailabilities[day] = newValue
                            }
                        ))
                    }
                }
            }
        }
    }
}
