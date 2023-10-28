import Foundation
import Inject
import SwiftUI

private final class ActivityPostModel: ObservableObject {
    @Published fileprivate var isLiked: Bool = false
    @Published fileprivate var scale: CGFloat = 1
    @Published fileprivate var degrees: Double = 0

    fileprivate init(liked: Bool) {
        isLiked = liked
    }

    fileprivate func animateHeart() {
        let rot = Double(Int.random(in: 6 ... 12))
        let scale = Double.random(in: 0.2 ... 0.3)
        let rev = Bool.random()

        let animations = [
            {
                self.scale += scale

                if rev {
                    self.degrees -= rot
                } else {
                    self.degrees += rot
                }
            },
            {
                self.scale -= scale / 2

                if rev {
                    self.degrees += rot * 2
                } else {
                    self.degrees -= rot * 2
                }
            },
            {
                self.scale = 1

                if rev {
                    self.degrees -= rot
                } else {
                    self.degrees += rot
                }
            },
        ]

        var delay: Double = 0
        for animation in animations {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    animation()
                }
            }
            delay += 0.2
        }
    }
}

struct ActivityPost: View {
    @EnvironmentObject var databaseCache: UsersCacheModel
    @StateObject private var viewModel: ActivityPostModel
    private var activityData: ActivityData
    private var id: String

    @State private var showingComments = false
    @State private var message: String = ""

    init(id: String, activity: ActivityData) {
        activityData = activity
        self.id = id
        _viewModel =
            StateObject(wrappedValue: ActivityPostModel(liked: activity.social.likes
                    .contains(AuthUtils.getCurrentUID())))
    }

    var body: some View {
        VStack(spacing: 14) {
            ActivityHeader(uid: activityData.uid, activityData: activityData)

            NavigationLink(destination: ActivityView(id: id, activity: activityData)) {
                VStack(spacing: 10) {
                    Text(activityData.social.title.isEmpty ? "Untitled Activity" : activityData.social.title)
                        .foregroundColor(Color("Text"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .alignFullWidth()

                    if !activityData.social.description.isEmpty {
                        Text(activityData.social.description)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .fontColor(.secondary)
                            .alignFullWidth()
                    }
                }
            }

            NavigationLink(destination: ActivityView(id: id, activity: activityData)) {
                ActivityPostStats(activityData: activityData)
            }

            NavigationLink(destination: ActivityView(id: id, activity: activityData)) {
                ActivityMapImage(id)
                    .cornerRadius(5)
                    .shadow(color: Color(.systemGray5), radius: 5, x: 0, y: 0)
            }
            .buttonStyle(PlainButtonStyle())

            HStack {
                Button(action: {
                    ActivityUtils.toggleLike(id: id, activity: activityData)
                    viewModel.isLiked.toggle()
                    viewModel.animateHeart()
                }) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .font(.title)
                        .scaleEffect(viewModel.scale)
                        .rotationEffect(.degrees(viewModel.degrees))
                }

                Text(activityData.social.likes.count.description)
                    .animation(.none, value: activityData.social.likes.contains(AuthUtils.getCurrentUID()))

                ActivityLikesList(activityData.social.likes)
                    .animation(.none, value: activityData.social.likes.contains(AuthUtils.getCurrentUID()))

                Spacer()

                Button {
                    showingComments.toggle()
                } label: {
                    Image(systemName: "message")
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .overlay(
                            NotificationCountView(value: Binding<Int>(
                                get: { activityData.social.comments.count },
                                set: { _ in }
                            ))
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .sheet(isPresented: $showingComments) {
                ZStack(alignment: .topLeading) {
                    Button(action: {
                        showingComments.toggle()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                            Text("Done")
                        }
                        .foregroundColor(.accentColor)
                        .font(.system(size: 16))
                        .padding(5)
                    }
                    .zIndex(1)
                    VStack {
                        ActivityMapImage(id)

                        Spacer(minLength: 0)
                            .frame(height: 10)

                        HStack {
                            Text(activityData.social.title.isEmpty ? "Untitled Activity" : activityData.social
                                .title)
                                .font(.title2)
                                .fontWeight(.semibold)

                            Spacer()

                            ActivityLikesList(activityData.social.likes, noLink: true, reverse: true)
                                .padding(.trailing, 10)
                        }
                    }
                }

                ScrollView {
                    ForEach(activityData.social.comments, id: \.self) { comment in
                        ActivityComment(comment)
                    }
                }

                Spacer()

                HStack {
                    TextField("Add a comment...", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        let comment = ActivityCommentData(
                            message: message,
                            time: Date(),
                            uid: AuthUtils.getCurrentUID()
                        )
                        message = ""
                        ActivityUtils.addComment(id: id, comment: comment)
                    }) {
                        Image(systemName: "paperplane")
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            showingComments.toggle()
                        }) {
                            Text("Done").fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color("SecondaryBackground"))
        .enduraDefaultBox()
    }
}

class ActivityPost_Previews: PreviewProvider {
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
