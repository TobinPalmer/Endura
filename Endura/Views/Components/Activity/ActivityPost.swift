import Foundation
import Inject
import SwiftUI

struct ActivityPost: View {
    @EnvironmentObject var databaseCache: UsersCacheModel
    private var activity: ActivityData
    private var id: String

    @State private var showingComments = false
    @State private var message: String = ""

    init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    var body: some View {
        VStack(spacing: 14) {
            ActivityHeader(uid: activity.uid, activityData: activity.withHeaderStats())

            NavigationLink(destination: ActivityView(id: id, activity: activity)) {
                VStack(spacing: 10) {
                    Text(activity.title.isEmpty ? "Untitled Activitiy" : activity.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if !activity.description.isEmpty {
                        Text(activity.description)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            NavigationLink(destination: ActivityView(id: id, activity: activity)) {
                ActivityPostStats(activityData: activity)
            }

            NavigationLink(destination: ActivityView(id: id, activity: activity)) {
                ActivityMapImage(id)
                    .cornerRadius(5)
                    .shadow(color: Color(.systemGray5), radius: 5, x: 0, y: 0)
            }

            .buttonStyle(PlainButtonStyle())

            HStack {
                Button(action: {
                    ActivityUtils.toggleLike(id: id, activity: activity)
                }) {
                    Image(systemName: "hand.thumbsup")
                        .font(.title)
                }

//        ZStack {
//          ForEach(0..<activity.likes.prefix(3).count, id: \.self) { i in
//            UserProfileLink(activity.likes[i]) {
//              ProfileImage(activity.likes[i], size: 30)
//                .offset(x: CGFloat(i) * 20, y: 0)
//                .shadow(radius: 1, x: -1, y: 0)
//            }
//          }
//        }
                ActivityLikesList(activity.likes)

                Spacer()

                Button {
                    showingComments.toggle()
                } label: {
                    let commentsBinding = Binding<Int>(
                        get: { activity.comments.count },
                        set: { _ in }
                    )
                    Image(systemName: "message")
                        .font(.title)
                        .overlay(
                            NotificationCountView(value: commentsBinding)
                                .offset(x: 10, y: 3)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .sheet(isPresented: $showingComments) {
                VStack {
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

                            Text(activity.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }

                VStack {
                    ScrollView {
                        ForEach(activity.comments, id: \.self) { comment in
                            ActivityComment(comment)
                        }
                    }

                    Spacer()

                    ActivityLikesList(activity.likes)
                        .padding(5)

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
                }
                .padding(5)
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
        .padding(8)
        .cornerRadius(10)
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(.systemBackground))
        .shadow(color: Color(.systemGray5), radius: 5, x: 0, y: 0)
        .cornerRadius(10)
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
