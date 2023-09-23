import Foundation
import SwiftUI

private enum ProfileViewPages {
    case activities
    case progress
}

private final class ProfileViewModel: ObservableObject {
    @Published fileprivate var currentPage: ProfileViewPages = .progress
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    public var body: some View {
        VStack {
            HStack {
                ProfileImage(AuthUtils.getCurrentUID(), size: 128)
                    .padding(.horizontal, 8)

                Text("Tobin Palmer")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            HStack {
                Button(action: {
                    viewModel.currentPage = .activities
                }, label: {
                    Text("Activities")
                        .font(.title2)
                        .foregroundColor(viewModel.currentPage == .activities ? Color("TextMuted") : Color("Text"))
                        .padding(.horizontal, 8)
                })

                Button(action: {
                    viewModel.currentPage = .progress
                }, label: {
                    Text("Progress")
                        .font(.title2)
                        .foregroundColor(viewModel.currentPage == .progress ? Color("TextMuted") : Color("Text"))
                        .padding(.horizontal, 8)
                })
            }

            switch viewModel.currentPage {
            case .activities:
                Text("Activities")
            case .progress:
                Text("Progress")
            }

            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}
