import Foundation
import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var databaseCache: UsersCacheModel
    @EnvironmentObject var activeUserModel: ActiveUserModel

    private var id: String
    private var activity: ActivityData
    @State var activityData: ActivityDataWithRoute?

    @State var analysisView: Bool = false

    public init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    ActivityHeader(uid: activity.uid, activityData: activity)

                    Text(activity.social.title)
                        .font(.title)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let activityData = activityData {
                        ActivityMap(activityData.data.routeData)
                            .frame(height: 300)
                            .environmentObject(ActivityViewModel(
                                activityData: activityData.getIndexedGraphData(),
                                routeLocationData: activityData.getIndexedRouteLocationData(),
                                interval: activityData.data.graphInterval
                            ))
                    } else {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 300)
                    }

                    ActivityGridStats(
                        activityData: activity,
                        topSpace: !(activityData?.data.routeData.isEmpty ?? false)
                    )

                    Button(action: {
                        analysisView = true
                    }) {
                        Text("View Analysis")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                    ActivitySplitGraph(splits: activity.stats.splits)
                }
            }
        }
        .sheet(isPresented: $analysisView) {
            NavigationStack {
                VStack {
                    if let activityData = activityData {
                        VStack {
                            Text(activity.social.title)
                                .font(.title)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ActivityMap(activityData.data.routeData)
                                .frame(height: 300)

                            ScrollView {
                                ActivityGraphsView(activityData)
                            }
                        }
                        .environmentObject(ActivityViewModel(
                            activityData: activityData.getIndexedGraphData(),
                            routeLocationData: activityData.getIndexedRouteLocationData(),
                            interval: activityData.data.graphInterval
                        ))
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            analysisView = false
                        }) {
                            Text("Done")
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        print("TODO: Edit")
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(action: {
                        ActivityUtils.deleteActivity(id: id)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }

                    if activeUserModel.data.role == .ADMIN {
                        Button(action: {
                            print("TODO: Banned")
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
            let activityDataWithRoute = await activity.withRouteData(id: id)
            withAnimation {
                activityData = activityDataWithRoute
            }
        }
    }
}
