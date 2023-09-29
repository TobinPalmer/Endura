import Foundation
import Inject
import SwiftUI

struct ActivityPost: View {
    @EnvironmentObject var databaseCache: UsersCacheModel
    private var activityData: ActivityData
    private var id: String

    @State private var showingComments = false
    @State private var message: String = ""

    init(id: String, activity: ActivityData) {
        activityData = activity
        self.id = id
    }

    var body: some View {
        VStack(spacing: 14) {
            ActivityHeader(uid: activityData.uid, activityData: activityData)

            NavigationLink(destination: ActivityView(id: id, activity: activityData)) {
                VStack(spacing: 10) {
                    Text(activityData.social.title.isEmpty ? "Untitled Activity" : activityData.social.title)
                        .foregroundColor(Color("Text"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if !activityData.social.description.isEmpty {
                        Text(activityData.social.description)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                }) {
                    Text("🎉")
                        .font(.title)
                }
                .buttonStyle(EnduraCircleButtonStyle(backgroundColor: activityData.social.likes
                        .contains(AuthUtils.getCurrentUID()) ? Color(.systemGray5) : .clear))

                Text(activityData.social.likes.count.description)

                ActivityLikesList(activityData.social.likes)

                Spacer()

                Button {
                    showingComments.toggle()
                } label: {
                    let commentsBinding = Binding<Int>(
                        get: { activityData.social.comments.count },
                        set: { _ in }
                    )
                    Image(systemName: "message")
                        .font(.title)
                        .overlay(
                            NotificationCountView(value: commentsBinding)
                                .offset(x: 10, y: 3)
                        )
                }
                .buttonStyle(EnduraCircleButtonStyle(backgroundColor: .clear, shadowColor: Color(.systemGray4)))
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
        .background(.white)
        .EnduraDefaultBox()
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
