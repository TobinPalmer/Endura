import FirebaseStorage
import Foundation
import SwiftUI

private final class PostUploadViewModel: ObservableObject {
    fileprivate final let headerTexts = [
        "Congratulations on Finishing Strong!",
        "You Did It! Run Complete!",
        "Mission Accomplished: Run Finished!",
        "Crossed the Finish Line with Determination!",
        "Your Run: Successfully Conquered!",
        "Celebrate Your Run's Triumph!",
        "Well Done, Finish Line Champion!",
        "Embrace the Victory of Your Completed Run!",
        "From Start to Finish, You Owned It!",
        "Another Run, Another Victory!",
        "Sweat, Smile, Finish: Check!",
        "Run Conquered, Goals Achieved!",
        "You Finished It! Celebrate!",
        "Run Complete: You Rocked It!",
        "Run Accomplished: Cheers to You!",
        "Your Run's Success: Applause Worthy!",
        "Run Triumphant: You Owned the Road!",
        "Strong Finisher, Stronger Runner!",
        "Finish Line Conquered with Grit!",
        "You Finished Strong: Fist Bumps!",
        "Completed Run: Success Unlocked!",
        "Run Done, Awesome Achieved!",
        "The End of the Run and Start of Pride!",
        "Run Complete: The Victory Lap Awaits!",
        "Victory Tune: Run Finished!",
        "From Steps to Success: Run Complete!",
        "Finished Run: Wear Your Accomplishment!",
        "Run Completed: Where's the Next Challenge?",
        "Crossed the Finish: Runner's Euphoria!",
        "Finished the Run: Time to Shine!",
        "Run Conquered: Revel in Your Success!",
        "Completing Runs, Achieving Dreams!",
        "From Strides to Accomplishment: Run Done!",
        "Run Completed: You Nailed It!",
        "Finish Line Beckoned, You Answered!",
        "Run Wrapped Up: Applause, Applause!",
        "You Finished the Run: Proud Moment!",
        "Mission Complete: You're the Running Hero!",
        "Done and Dusted: Run Accomplished!",
        "Run Finished: Memories and Milestones!",
        "From the Road to Glory: Run Completed!",
        "Victorious Finisher: That's You!",
        "Crossed the Finish Line: Keep Soaring!",
        "Run Accomplished: Inspiring the Next Step!",
        "You Finished It: Now Rest and Reflect!",
        "Done with the Run: Cheers to You!",
        "Run Completed: Your Hard Work Paid Off!",
        "Triumph in Every Step: Run Finished!",
        "Finish Line Crossed: Your Achievement!",
        "Run Conquered: Your Victory Story!",
        "Finished Strong: Your Running Legacy!",
        "The End of the Run, The Start of Triumph!",
    ]
}

struct PostUploadView: View {
    @EnvironmentObject var activeUser: ActiveUserModel
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = PostUploadViewModel()
    private let activityData: ActivityDataWithRoute
    private let mapRef: Binding<(any View)?>
    private let geometryRef: Binding<GeometryProxy?>

    public init(
        activityData: ActivityDataWithRoute,
        mapRef: Binding<(any View)?>,
        geometryRef: Binding<GeometryProxy?>
    ) {
        self.activityData = activityData
        self.geometryRef = geometryRef
        self.mapRef = mapRef
    }

    public var body: some View {
        VStack {
            let indexSeed = activityData.distance + activityData.duration
            let index = Int(indexSeed) % viewModel.headerTexts.count

            let headerText = viewModel.headerTexts[index]

            Text(headerText).font(.title)

            Spacer()

            Button("Done") {
                dismiss()
            }
            .buttonStyle(EnduraButtonStyle())
        }
        .task {
            let storage = Storage.storage()

            var activityData = activityData
            activityData.visibility = activeUser.settings.data.defaultActivityVisibility

            do {
                if let mapRef = mapRef.wrappedValue, let geometryRef = geometryRef.wrappedValue {
                    let image = mapRef.takeScreenshot(
                        origin: geometryRef.frame(in: .global).origin,
                        size: geometryRef.size
                    )

                    try ActivityUtils.uploadActivity(activity: activityData, image: image, storage: storage)
                } else {
                    try ActivityUtils.uploadActivity(activity: activityData)
                }

                activeUser.training.processNewActivity(activityData)
            } catch {
                Global.log.error("Error uploading activity: \(error)")
            }
        }
    }
}
