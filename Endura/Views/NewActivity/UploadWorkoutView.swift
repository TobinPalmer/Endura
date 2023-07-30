//
// Created by Tobin Palmer on 7/21/23.
//

import Foundation
import SwiftUI
import HealthKit
import MapKit
import Charts
import FirebaseFirestore
import FirebaseCore
import SwiftUICharts

//public class GraphPositionController: ObservableObject {
//    @Published var positionX: CGFloat? = nil
//    @Published var positionY: CGFloat? = nil
//}

@MainActor fileprivate final class PreviewWorkoutModel: ObservableObject {
    @Published public var number = 2

    final fileprivate func getEnduraWorkout(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
        do {
            return try await HealthKitUtils.workoutToActivityData(workout)
        } catch {
            throw error
        }
    }
}

public struct PreviewWorkoutView: View {
    private var workout: HKWorkout
    @State private var enduraWorkout: ActivityDataWithRoute?
    @ObservedObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()
//    @ObservedObject fileprivate var graphPosition = GraphPositionController()

    init(workout: HKWorkout) {
        self.workout = workout
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Afternoon Run").font(.title)
            if let enduraWorkout = enduraWorkout {
                Text("\(enduraWorkout.duration) \(enduraWorkout.distance)")

                ActivityMap(enduraWorkout.data.routeData)
                        .frame(height: 300)
                        .environmentObject(LineGraphViewModel())
//                    .environmentObject(graphPosition)

                var heartRate = [(Date, Double)]()
                var pace = [(Date, Double)]()

//                let _ = enduraWorkout.routeData.forEach { val in
//                    heartRate.append(val.heartRate)
//                    pace.append(val.pace)
//                }

                let _ = enduraWorkout.data.graphData.compactMap { val in
                    if (!val.heartRate.isNaN) {
                        heartRate.append((val.timestamp, val.heartRate))
                    }
                    if (!val.pace.isNaN) {
                        pace.append(((val.timestamp, val.pace)))
                    }
                }

                GeometryReader { geometry in
                    VStack {
                        VStack {
                            LineGraphGroup {
                                if (!pace.isEmpty) {
                                    LineGraph(data: pace, step: enduraWorkout.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm)
                                } else {
                                    Text("No pace data available")
                                }
                                if (!heartRate.isEmpty) {
                                    LineGraph(data: heartRate, step: enduraWorkout.data.graphInterval, height: 200, valueModifier: ConversionUtils.round)
                                } else {
                                    Text("No heart rate data available")
                                }
                            }
                                    .environmentObject(LineGraphViewModel())
//                                .environmentObject(graphPosition)
                        }
                                .frame(width: geometry.size.width - 50, height: geometry.size.height)
                    }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                }
//                LineGraph(data: pace, height: 200, valueModifier: ConversionUtils.convertMpsToMpm)
//                    .padding()
//
//                LineGraph(data: heartRate, height: 200)
//                    .padding()

//                LineChartView(data: heartRate, title: "Heart Rate", legend: "BPM", form: ChartForm.extraLarge, dropShadow: false)
//                    .padding()
//
//                LineChartView(data: pace, title: "Pace", legend: "Min/Mile", form: ChartForm.extraLarge, dropShadow: false, valueSpecifier: "%.2f")
//                    .padding()


//                let heartRate = enduraWorkout.routeData.map { val in
//                    (val.timestamp, val.heartRate)
//                }
//
//                let _ = enduraWorkout.routeData.forEach { val in
//                    print("loop", val.heartRate, val.timestamp)
//                }
//
//                let pace = enduraWorkout.routeData.map { val in
//                    (val.timestamp, val.pace)
//                }
//
//                let heartRateData = heartRate.compactMap {
//                    $0.1 != 0.0 ? $0 : nil
//                }
//
//                let paceData = previewWorkoutModel.cleanPaceData(pace)
//
//                let _ = heartRateData.forEach { val in
//                    print("heart rate", val.0, val.1)
//                }
//
//                Chart(heartRateData, id: \.0) { tuple in
//                    LineMark(
//                        x: .value("X values", tuple.0),
//                        y: .value("Y values", tuple.1)
//                    ).interpolationMethod(.catmullRom)
//                        .lineStyle(StrokeStyle(lineWidth: 3, dash: [0]))
//                }
//
//                Chart(pace, id: \.0) { tuple in
//                    LineMark(
//                        x: .value("X values", tuple.0),
//                        y: .value("Y values", tuple.1)
//                    ).interpolationMethod(.catmullRom)
//                        .lineStyle(StrokeStyle(lineWidth: 3, dash: [0]))
//                }


//                let heartRateTuple = enduraWorkout.routeData.map { val in
//                    (val.index, val.heartRate)
//                }
//                let paceTuple = enduraWorkout.location.map { val in
//                    (val.index, val.speed)
//                }
//
//                if !heartRateTuple.isEmpty {
//                    Chart(heartRateTuple, id: \.0) { tuple in
//                        LineMark(
//                            x: .value("X values", tuple.0),
//                            y: .value("Y values", tuple.1)
//                        )
//                    }
//                } else {
//                    Text("No heart rate data available")
//                }
//
//                if !paceTuple.isEmpty {
//                    Chart(paceTuple, id: \.0) { tuple in
//                        LineMark(
//                            x: .value("X values", tuple.0),
//                            y: .value("Y values", tuple.1)
//                        )
//                    }
//                } else {
//                    Text("No pace data available")
//                }
//
//                if !enduraWorkout.location.isEmpty {
//                    ActivityMap(enduraWorkout)
//                } else {
//                    Text"No route data available")
//                }

                Button {
                    Task {
                        do {
//                            try Firestore.firestore().collection("activities").addDocument(data: enduraWorkout)
                        } catch {
                            print("Error uploading workout: \(error)")
                        }
                    }
                } label: {
                    Text("Upload")
                }

            } else {
                ProgressView {
                    Text("Loading...")
                }
            }
        }
                .task {
                    do {
                        enduraWorkout = try await previewWorkoutModel.getEnduraWorkout(workout)
                    } catch WorkoutErrors.noWorkout {
                        print("No workout to get heart rate graph")
                    } catch {
                        print("Error getting heart rate graph")
                    }
                }
        //            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        //            .task {
        //                do {
        //                    enduraWorkout = try await previewWorkoutModel.getEnduraWorkout(workout)
        //                } catch WorkoutErrors.noWorkout {
        //                    print("No workout to get heart rate graph")
        //                } catch {
        //                    print("Error getting heart rate graph")
        //                }
        //            }
    }
}
