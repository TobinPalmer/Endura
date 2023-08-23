import Foundation
import SwiftUI

struct ActivityView: View {
    @StateObject var activityViewModel = ActivityViewModel()
    @EnvironmentObject var databaseCache: UsersCacheModel

    private var id: String
    private var activity: ActivityData
    @State var activityData: ActivityDataWithRoute?

    public init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    var body: some View {
        VStack {
            if let activityData = activityData {
                ScrollView(.vertical) {
                    VStack {
                        ActivityHeader(uid: activity.uid, activityData: activityData.withHeaderStats())

                        Text(activity.title)
                            .font(.title)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ActivityMap(activityData.data.routeData)
                            .frame(height: 300)

                        ActivityGridStats(activityData: ActivityDataWithRoute.withGridStats(activityData)(), topSpace: !activityData.data.routeData.isEmpty)

                        VStack {
                            ActivityGraphsView(activityData)
                        }
                    }
                    .environmentObject(activityViewModel)
                }
            } else {
                ScrollView {
                    ActivityHeader(uid: "", activityData: nil, placeholder: true)

                    Text("-----------------------")
                        .font(Font.custom("FlowBlock-Regular", size: 30, relativeTo: .title))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack {
                        Text("Loading...")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: 300)
                    .foregroundColor(Color.red)
                    .border(.red)

                    ActivityGridStats(activityData: nil, placeholder: true)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        print("Edit")
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(action: {
                        ActivityUtils.deleteActivity(id: id)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }

                    if databaseCache.getUserData(AuthUtils.getCurrentUID())?.role == .ADMIN {
                        Button(action: {
                            print("Banned")
                        }) {
                            Label("Ban User", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .padding()
        .task {
            activityData = await activity.withRouteData(id: id)
        }
    }
}
