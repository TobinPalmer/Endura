import Foundation
import SwiftUI

private final class FindUsersViewModel: ObservableObject {}

struct FindUsersView: View {
    @StateObject private var viewModel = FindUsersViewModel()

    var body: some View {
        VStack {
            Text("Find Users")
        }
    }
}
