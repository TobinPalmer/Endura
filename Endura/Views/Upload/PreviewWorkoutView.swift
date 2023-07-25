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

@MainActor fileprivate final class PreviewWorkoutModel: ObservableObject {
    final fileprivate func getEnduraWorkout(_ workout: HKWorkout) async throws -> ActivityData {
        do {
            return try await HealthKitUtils.workoutToActivityData(workout)
        } catch {
            throw error
        }
    }

//    final fileprivate func cleanPaceData(_ data: [(Double, Date)]) -> [(Double, Date)] {
//        let sortedData = data.sorted {
//            $0.1 < $1.1
//        }
//
//        var smoothedData = [sortedData.first!]
//
//        for tuple in sortedData.dropFirst() {
//            let lastAddedTuple = smoothedData.last!
//            if abs((tuple.0 - lastAddedTuple.0)) > 0.5 {
//                smoothedData.append(tuple)
//            }
//
//            if abs((tuple.0 - lastAddedTuple.0)) > 0.25 {
//                smoothedData.append(tuple)
//            }
//        }
//
//        let filteredData = smoothedData.reduce([(Double, Date)](), { (result, tuple) -> [(Double, Date)] in
//            guard let last = result.last else {
//                return [tuple]
//            }
//            if abs(last.0 - tuple.0) <= 0.20 {
//                return result + [tuple]
//            } else {
//                return result
//            }
//        })
//
//        return filteredData
//    }

//    final fileprivate func cleanPaceData(_ data: HeartRateGraph) -> HeartRateGraph {
//        let sortedData = data.sorted {
//            $0.1 < $1.1
//        }
//
//        var smoothedData: HeartRateGraph = [sortedData.first!]
//
//        for tuple in sortedData.dropFirst() {
//            let lastAddedTuple = smoothedData.last!
//
//            if abs((tuple.1 - lastAddedTuple.1)) <= 0.25 {
//                smoothedData.append(tuple)
//            } else {
//                let newTuple = (lastAddedTuple.0, tuple.1)
//                smoothedData.append(newTuple)
//            }
//        }
//
//        return smoothedData
//    }


//    final fileprivate func cleanHeartRateData(_ data: HeartRateGraph) -> HeartRateGraph {
//        let filteredData = data.compactMap {
//            $0.1 != 0.0 ? $0 : nil
//        }
//
//        return filteredData
//    }
}

public struct PreviewWorkoutView: View {
    private var workout: HKWorkout
    @State private var enduraWorkout: ActivityData?
    @ObservedObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()

    init(workout: HKWorkout) {
        self.workout = workout
        Task {
            //            async let data = try WorkoutUtils.workoutToEnduraWorkout(workout)
            //            let _ = try await Firestore.firestore().collection("activities").addDocument(from: data)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Afternoon Run").font(.title)
            if let enduraWorkout = enduraWorkout {
                Text("\(enduraWorkout.duration) \(enduraWorkout.distance)")

                var heartRate = [Double]()
                var pace = [Double]()

                let _ = enduraWorkout.routeData.forEach { val in
                    heartRate.append(val.heartRate)
                    pace.append(val.pace)
                }

                LineGraphGroup {
                    LineGraph(data: pace, height: 200, valueModifier: ConversionUtils.convertMpsToMpm)
                        .padding()

                    LineGraph(data: heartRate, height: 200)
                        .padding()
                }
                    .environmentObject(LineGraphViewModel()) // remove this line
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
//                    Text("No route data available")
//                }

                Button {
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
