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

struct MapView: UIViewRepresentable {
    @Binding var locations: [CLLocation]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)

        if !locations.isEmpty {
            let coordinates = locations.map {
                $0.coordinate
            }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            uiView.addOverlay(polyline)

            let region = MKCoordinateRegion(coordinates: coordinates)
            uiView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
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
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

extension MKCoordinateRegion {
    init(coordinates: [CLLocationCoordinate2D]) {
        var minLat = coordinates.first?.latitude ?? 0
        var maxLat = coordinates.first?.latitude ?? 0
        var minLon = coordinates.first?.longitude ?? 0
        var maxLon = coordinates.first?.longitude ?? 0

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.2,
            longitudeDelta: (maxLon - minLon) * 1.2
        )

        self.init(center: center, span: span)
    }
}

extension CLLocation: Identifiable {
    public var id: String {
        UUID().uuidString
    }
}
