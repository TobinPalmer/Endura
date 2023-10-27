import Foundation
import HealthKit
import SwiftUI

private struct IdentifiableDate: Identifiable, Hashable {
    let id: UUID
    let date: Date
}

@MainActor final class UploadsViewModel: ObservableObject {
    @Published fileprivate final var uploads: [HKWorkout?] = []
    private var offset: Int = 0

    fileprivate final func activityToIcon(activityName: String) -> String {
        switch activityName {
        case "Running":
            return "figure.run"
        case "Cycling":
            return "figure.outdoor.cycle"
        case "Walking":
            return "figure.walk"
        case "Swimming":
            return "figure.pool.swim"
        case "Elliptical":
            return "figure.walk"
        case "Other":
            return "figure.walk"
        default:
            return "figure.walk"
        }
    }

    fileprivate final func getActivities(_ limitTo: Int) async {
        guard limitTo > 0 else {
            return
        }

        guard uploads.count > limitTo else {
            do {
                let workouts = try await HealthKitUtils.getListOfWorkouts(limitTo: limitTo, offset: offset)
                uploads.append(contentsOf: workouts)
                offset += workouts.count
            } catch {
                Global.log.error("Error: \(error)")
            }
            return
        }
    }
}

struct NewActivityView: View {
    @EnvironmentObject private var navigation: NavigationModel
    @ObservedObject private var uploadsViewModel = UploadsViewModel()
    @State private var totalItemsLoaded: Int = 0
    @State private var activityEndDatesToUUIDs: [Date: UUID] = [:]
    @State private var isAuthorized = HealthKitUtils.isAuthorized()

    @State private var selectionMode = false
    @State private var selectedActivities: Set<HKWorkout> = []

    var body: some View {
        VStack {
            if !isAuthorized {
                Text("Please authorize Apple Health to continue.")
                Button("Authorize") {
                    HealthKitUtils.requestAuthorization { success in
                        isAuthorized = success
                        print("setting isAuthorized to \(success)")
                        print("but healthKit is \(HealthKitUtils.isAuthorized())")
                    }
                }
            } else {
                let groupedActivities = Dictionary(grouping: uploadsViewModel.uploads.compactMap {
                    $0
                }) { workout in
                    Calendar.current.startOfDay(for: workout.startDate)
                }
                let sortedDates = groupedActivities.keys.sorted(by: >)

                if sortedDates.isEmpty {
                    VStack {
                        ZStack {
                            Image(systemName: "nosign")
                                .font(.system(size: 150))
                                .fontColor(.primary)
                                .zIndex(1)

                            Image(systemName: "figure.run")
                                .font(.system(size: 80))
                                .fontColor(.muted)
                        }

                        VStack(spacing: 6) {
                            Text("No activities found")
                                .font(.title2)
                                .fontColor(.primary)
                                .fontWeight(.bold)

                            Text("Record a workout on your Apple Watch to see it here!")
                                .fontColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 26)
                    }
                }

                List(selection: $selectedActivities) {
                    ForEach(sortedDates, id: \.self) { date in
                        Section(header: Text("\(date.formatted(date: .abbreviated, time: .omitted))")) {
                            ForEach(groupedActivities[date]!, id: \.self) { activity in
                                NavigationLink(destination: UploadWorkoutView(workout: activity)) {
                                    let workoutType = activity.workoutActivityType.name
                                    let workoutDistance = (activity.totalDistance?.doubleValue(for: .mile()) ?? 0.0)
                                        .rounded(toPlaces: 2).removeTrailingZeros()
                                    Label {
                                        Text(
                                            "\(activity.startDate.formatted(date: .omitted, time: .shortened)) • \(workoutDistance) mi"
                                        )
                                    } icon: {
                                        if ActivityUtils.isActivityUploaded(activity) {
                                            Image(systemName: "checkmark").font(.title2).foregroundColor(.green)
                                        } else {
                                            Image(systemName: uploadsViewModel
                                                .activityToIcon(activityName: workoutType))
                                                .font(.title2)
                                        }
                                    }
                                    .frame(height: 30)
                                    .selectionDisabled(ActivityUtils.isActivityUploaded(activity))
                                    .tag(activity)
                                }
                            }
                        }
                    }
                }
                .onChange(of: selectedActivities) { _ in
                    if !selectionMode {
                        self.selectedActivities = []
                    }
                }
                .environment(\.editMode, .constant(selectionMode ? EditMode.active : EditMode.inactive))
                .toolbar {
                    if !sortedDates.isEmpty {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(selectionMode ? "Cancel" : "Select") {
                                withAnimation {
                                    selectionMode.toggle()
                                    selectedActivities = []
                                }
                            }
                        }
                    }
                }
                .task {
                    await uploadsViewModel.getActivities(100)
                }
            }
            if selectionMode {
                Button("Upload \(selectedActivities.count) Activities") {
                    for activity in selectedActivities {
                        print("Uploading \(activity.workoutActivityType.name)...")
                    }
                    withAnimation {
                        selectionMode.toggle()
                        selectedActivities = []
                    }
                }
                .buttonStyle(EnduraNewButtonStyle())
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}
