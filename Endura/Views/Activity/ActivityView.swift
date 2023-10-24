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
        ZStack {
            Color("Background")
                .ignoresSafeArea()

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
                                .cornerRadius(16)
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

                        DisclosureGroup("Splits") {
                            ActivitySplitGraph(splits: activity.stats.splits)
                                .padding(.vertical, 16)
                        }
                        .padding(16)
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(16)

                        Button("View Analysis") {
                            analysisView = true
                        }
                        .buttonStyle(EnduraNewButtonStyle())
                    }
                    .enduraPadding()
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
            .task {
                let activityDataWithRoute = await activity.withRouteData(id: id)
                withAnimation {
                    activityData = activityDataWithRoute
                }
            }
        }
    }
}
