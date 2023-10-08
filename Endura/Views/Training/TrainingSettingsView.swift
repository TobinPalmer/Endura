import Foundation
import SwiftUI

struct TrainingSettingsView: View {
    @EnvironmentObject var activeUser: ActiveUserModel
    @State var showingAlert = false

    var body: some View {
        List {
            Section(header: Text("Day Availabilities")) {
                ForEach(0 ..< 7) { day in
                    Toggle("\(WeekDay(rawValue: day)!.getShortName())", isOn: Binding(
                        get: {
                            activeUser.settings.data.training.dayAvailabilities[day] ?? true
                        },
                        set: { newValue in
                            if activeUser.settings.data.training.dayAvailabilities.filter({ $0.value == false })
                                .count >= 3, newValue == false
                            {
                                showingAlert = true
                                return
                            }
                            activeUser.settings.data.training.dayAvailabilities[day] = newValue
                        }
                    ))
                }
            }
            NavigationLink(
                destination: Text("Routines")
            ) {
                Text("Routines")
                    .badge(4)
            }
        }
        .alert(Text("You must have at least 4 days available for training"), isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
