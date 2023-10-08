import Foundation
import SwiftUI

struct TrainingSettingsView: View {
    @EnvironmentObject var activeUser: ActiveUserModel
    @State var showingBadAlert = false
    @State var showingConfirmAlert = false
    @State var dayToRemove: Int? = nil

    var body: some View {
        List {
            Section(
                header: Text("Day Availabilities"),
                footer: Text(
                    "Only unselect days you are always unavailable for training. You can always edit individual days later."
                )
            ) {
                ForEach(0 ..< 7) { day in
                    Toggle("\(WeekDay(rawValue: day)!.getShortName())", isOn: Binding(
                        get: {
                            activeUser.settings.data.training.dayAvailabilities[day] ?? true
                        },
                        set: { newValue in
                            if activeUser.settings.data.training.dayAvailabilities.filter({ $0.value == false })
                                .count >= 3, newValue == false
                            {
                                showingBadAlert = true
                                return
                            }
                            if newValue == false {
                                showingConfirmAlert = true
                                dayToRemove = day
                            } else {
                                activeUser.settings.data.training.dayAvailabilities[day] = newValue
                            }
                        }
                    ))
                }
            }
            Section(header: Text("Routines"), footer: Text("Edit your pre-run or post-run routines")) {
                NavigationLink(
                    destination: Text("Edit Routines")
                ) {
                    Text("Routines")
                        .badge(4)
                        .badgeProminence(.increased)
                }
            }
        }
        .alert(Text("You must have at least 4 days available for training"), isPresented: $showingBadAlert) {
            Button("OK", role: .cancel) {}
        }
        .alert(Text("Are you sure you ALWAYS will be unavailable on this day?"),
               isPresented: $showingConfirmAlert)
        {
            Button("Yes", role: .destructive) {
                activeUser.settings.data.training.dayAvailabilities[dayToRemove!] = false
            }
            Button("No", role: .cancel) {}
        }
    }
}
