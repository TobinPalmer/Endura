import Foundation
import SwiftUI

private final class SignupFinishedViewModel: ObservableObject {}

struct SignupFinishedView: View {
    @StateObject private var viewModel = SignupFinishedViewModel()
    @EnvironmentObject var formInfo: SignupFormInfo

    public var body: some View {
        VStack {
            Text("Welcome, \(formInfo.schedule.description)")

            NavigationLink(destination: DashboardView()) {
                Text("Continue")
            }
        }
        .toolbar {}
        .navigationBarBackButtonHidden(true)
        .task {
            AuthUtils.createUser(email: formInfo.email, password: formInfo.password, userData: formInfo.toUserDocument(), userTrainingData: formInfo.toUserTrainingData())
        }
    }
}
