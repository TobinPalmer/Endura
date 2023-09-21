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

                        VStack {
                            let fastestSplit = activity.splits.min {
                                $0.pace < $1.pace
                            }
                            ForEach(activity.splits, id: \.self) { split in
                                HStack {
//                  Text("\(split.distance.removeTrailingZeros()) mi")
//                                    Text("Pace: \(FormattingUtils.secondsToFormattedTime(split.pace))")
//                  Text("Time: \(FormattingUtils.secondsToFormattedTime(split.time))")

                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .frame(width: 200, height: 20)
                                            .foregroundColor(.red)

                                        let width = min(200, 200 * CGFloat(fastestSplit!.pace / split.pace))
                                        let _ = print(width)

                                        Rectangle()
                                            .frame(maxWidth: width)
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .environmentObject(ActivityViewModel(activityData: activityData.getIndexedGraphData(), routeLocationData: activityData.getIndexedRouteLocationData(), interval: activityData.data.graphInterval))
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
        .sheet(isPresented: $analysisView) {
            if let activityData = activityData {
                VStack {
                    Text(activity.title)
                        .font(.title)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ActivityMap(activityData.data.routeData)
                        .frame(height: 300)

                    ScrollView {
                        ActivityGraphsView(activityData)
                    }
                }
                .environmentObject(ActivityViewModel(activityData: activityData.getIndexedGraphData(), routeLocationData: activityData.getIndexedRouteLocationData(), interval: activityData.data.graphInterval))
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
            activityData = await activity.withRouteData(id: id)
        }
    }
}
