//
// Created by Brandon Kirbyson on 7/28/23.
//

import Foundation
import SwiftUI

extension UIView {
    var renderedImage: UIImage {
        // rect of capure
        let rect = self.bounds
        // create the context of bitmap
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

extension View {
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.renderedImage
    }
}

public struct ActivityView: View {
    @StateObject var activityViewModel = ActivityViewModel()

    private var id: String
    private var activity: ActivityData
    @State var activityData: ActivityDataWithRoute?

    public init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    public var body: some View {
        VStack {
            if let activityData = activityData {
                ScrollView(.vertical) {
                    HStack {
                        Text("\(ConversionUtils.metersToMiles(activityData.distance))")
                        Text("\(FormattingUtils.secondsToFormattedTime(activityData.duration))")
                    }


                    ActivityMap(activityData.data.routeData)
                        .frame(height: 300)
                        .environmentObject(activityViewModel)

//                    Button("Take Screenshot of Map") {
//                        let image = map.snapshot()
//                        print("Image", image, "data", image.pngData())
//                    }

                    let (paceGraph, heartRateGraph) = activityData.getPaceAndHeartRateGraphData()
                    if (!paceGraph.isEmpty) {
                        LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
                            .environmentObject(activityViewModel)
                    } else {
                        Text("No pace data available")
                    }
                    if (!heartRateGraph.isEmpty) {
                        LineGraph(data: heartRateGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: HeartRateLineGraphStyle())
                            .environmentObject(activityViewModel)
                    } else {
                        Text("No heart rate data available")
                    }
                }
            }
        }
            .task {
                activityData = await activity.withRouteData(id: id)
            }
    }
}