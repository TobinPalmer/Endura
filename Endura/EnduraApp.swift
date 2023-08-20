import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        AuthUtils.initAuth()

        HealthKitUtils.requestAuthorization()
        NotificationUtils.requestPermission()

        HealthKitUtils.subscribeToNewWorkouts()
        return true
    }
}

@main
struct EnduraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(NavigationModel.instance).environmentObject(DatabaseCacheModel())
        }
    }
}
