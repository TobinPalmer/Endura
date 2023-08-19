//
//  SignupFinishedView.swift created on 8/13/23.
//

import Foundation
import SwiftUI

private final class SignupFinishedViewModel: ObservableObject {}

struct SignupFinishedView: View {
    @StateObject private var viewModel = SignupFinishedViewModel()
    @EnvironmentObject var formInfo: SignupFormInfo

    public var body: some View {
        VStack {
            Text("Welcome, \(formInfo.firstName)")
        }
    }
}
