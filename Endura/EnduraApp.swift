import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        AuthUtils.initAuth()

//        HealthKitUtils.requestAuthorization()
//        NotificationUtils.requestPermission()

        HealthKitUtils.subscribeToNewWorkouts()

        #if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif
        return true
    }
}

struct InjectedContentView: View {
    let persistenceController = PersistenceController.shared

    var body: some View {
        ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext).environmentObject(NavigationModel.instance).environmentObject(UsersCacheModel())
    }
}

@main
struct EnduraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            InjectedContentView()
        }
    }
}
