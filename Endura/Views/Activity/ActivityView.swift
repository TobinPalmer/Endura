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

//                        Text(activity.social.title)
//                            .font(.title)
//                            .fontWeight(.bold)
//                            .alignFullWidth()

                        if !activity.social.description.isEmpty {
                            Text(activity.social.description)
                                .font(.body)
                                .fontColor(.secondary)
                                .alignFullWidth()
                                .padding(.bottom, 10)
                        }

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

                        Button("View Analysis") {
                            analysisView = true
                        }
                        .buttonStyle(EnduraNewButtonStyle())
                        .padding(.top, 16)

                        DisclosureGroup("Splits") {
                            ActivitySplitGraph(splits: activity.stats.splits)
                                .padding(.vertical, 16)
                        }
                        .padding(16)
                        .enduraDefaultBox()
                    }
                    .enduraPadding()
                }
            }
            .sheet(isPresented: $analysisView) {
                NavigationStack {
                    VStack {
                        if let activityData = activityData {
                            VStack {
                                ActivityMap(activityData.data.routeData)
                                    .frame(height: 300)

                                ScrollView {
                                    ActivityGraphsView(activityData)
                                }
                            }
                            .ignoresSafeArea(edges: .top)
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
            .navigationBarTitle(activity.social.title, displayMode: .inline)
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
