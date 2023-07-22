//
// Created by Tobin Palmer on 7/22/23.
//

import Foundation
import MapKit
import SwiftUI
import HealthKit

@MainActor
public final class ActivityMapModel: ObservableObject {
    fileprivate final func workoutToRoute(workout: HKWorkout) async throws -> [HKWorkoutRoute] {
        do {
            return try await HealthKitUtils.getWorkoutRoute(workout: workout)
        } catch {
            throw error
        }
    }
}

public struct ActivityMap: View {
    @StateObject private var activityMapModel = ActivityMapModel()
    @State private var routes: [HKWorkoutRoute] = []
    @State private var workout: HKWorkout
    @State private var locations: [CLLocation] = []

    init(workout: HKWorkout) {
        self.workout = workout
    }

    public var body: some View {
        VStack {
            Text("Map")
//            Text(locations.debugDescription)
            MapView(locations: $locations)
        }
            .task {
                do {
                    routes = try await activityMapModel.workoutToRoute(workout: workout)
                    for route in routes {
                        let locations = try await HealthKitUtils.getLocationData(for: route)
                        for location in locations {
                            self.locations.append(location)
                        }
                    }
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
    }
}

fileprivate struct MapView: UIViewRepresentable {
    @Binding var locations: [CLLocation]

    fileprivate func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    fileprivate func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)

        if !locations.isEmpty {
            let coordinates = locations.map {
                $0.coordinate
            }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            uiView.addOverlay(polyline)

            let region = MKCoordinateRegion(coordinates: coordinates)
            uiView.setRegion(region, animated: false)
        }
    }

    fileprivate func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .orange
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
