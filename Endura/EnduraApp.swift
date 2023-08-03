//
//  EnduraApp.swift
//  Endura
//
//  Created by Tobin Palmer on 7/15/23.
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        AuthUtils.initAuth()

        HealthKitUtils.requestAuthorization()
        NotificationUtils.requestPermission()

        HealthKitUtils.subscribeToStepCountUpdates()
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
