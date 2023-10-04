import Foundation
import SwiftUI

private enum ProfileViewPages {
    case activities
    case progress
    case achievements
}

private final class ProfileViewModel: ObservableObject {
    @Published fileprivate var currentPage: ProfileViewPages = .progress
}

struct ProfileView: View {
    @EnvironmentObject var activeUser: ActiveUserModel
    @StateObject private var viewModel = ProfileViewModel()

    public var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    ProfileImage(AuthUtils.getCurrentUID(), size: 128)
                        .padding(.horizontal, 8)

                    VStack(alignment: .leading) {
                        Text(activeUser.data.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                            .padding(.bottom, 8)

                        Text("Friends")
                            .font(.caption)
                            .fontColor(.secondary)

                        HStack {
                            ForEach(0 ..< activeUser.data.friends.count, id: \.self) { i in
                                let maxDisplay = 5
                                if i < maxDisplay {
                                    let friend = activeUser.data.friends[i]
                                    UserProfileLink(friend) {
                                        ProfileImage(friend, size: 32)
                                            .offset(x: CGFloat(-i * 16))
                                    }
                                } else if i == maxDisplay {
                                    Text("...\(activeUser.data.friends.count - maxDisplay) more")
                                        .font(.body)
                                        .fontColor(.secondary)
                                        .offset(x: CGFloat(-i * 16) + 8)
                                }
                            }
                        }
                    }
                    .alignFullWidth()
                }

                Picker(selection: $viewModel.currentPage, label: Text("Picker")) {
                    Text("Activities").tag(ProfileViewPages.activities)
                    Text("Progress").tag(ProfileViewPages.progress)
                    Text("Achievements").tag(ProfileViewPages.achievements)
                        .background(.clear)
                }
                .pickerStyle(SegmentedPickerStyle())

                switch viewModel.currentPage {
                case .activities:
                    ActivityList(singlePerson: AuthUtils.getCurrentUID(), fullWidth: false)
                case .progress:
                    Text("Progress")
                    NavigationLink(destination: TrainingSetupView()) {
                        Text("Setup Training")
                    }
                case .achievements:
                    Text("Achievements")
                }

                Spacer()
            }
            .enduraPadding()
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
