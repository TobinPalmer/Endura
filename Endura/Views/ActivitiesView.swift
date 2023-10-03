import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import HealthKit
import Inject
import SwiftUI

struct ActivitiesView: View {
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            ActivityList()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: NewActivityView()) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell")
                        .overlay(
                            NotificationCountView(value: .constant(50))
                        )
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: FindUsersView()) {
                    Image(systemName: "person.2")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                UserProfileLink(AuthUtils.getCurrentUID()) {
                    ProfileImage(AuthUtils.getCurrentUID(), size: 30)
                }
            }
        }
    }
}

class ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        InjectedContentView()
    }

    #if DEBUG
        @objc class func injected() {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.rootViewController =
                UIHostingController(rootView: InjectedContentView())
        }
    #endif
}
