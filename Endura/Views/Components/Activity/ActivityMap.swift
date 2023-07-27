//
// Created by Tobin Palmer on 7/22/23.
//

import Foundation
import MapKit
import SwiftUI
import HealthKit

//@MainActor
//public final class ActivityMapModel: ObservableObject {
//    fileprivate final func workoutToRoute(workout: HKWorkout) async throws -> [HKWorkoutRoute] {
//        do {
//            return try await HealthKitUtils.getWorkoutRoute(workout: workout)
//        } catch {
//            throw error
//        }
//    }
//}

public struct ActivityMap: View {
//    @StateObject private var activityMapModel = ActivityMapModel()
//    @State private var routes: [HKWorkoutRoute] = []
//    private var workout: ActivityData
    @State private var routeData: [RouteData];

    public init(_ route: [RouteData]) {
        self.routeData = route
    }

    public var body: some View {
        VStack {
            if !routeData.isEmpty {
                MapView(routeData: $routeData)
                        .frame(height: 300)
            } else {
                Text("No route data available")
            }
        }
    }
}

fileprivate struct MapView: UIViewRepresentable {
    @Binding var routeData: [RouteData]

    fileprivate func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator


        return mapView
    }

    fileprivate func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)

        if !routeData.isEmpty {
            let coordinates = routeData.map {
                CLLocationCoordinate2D(latitude: $0.location.latitude, longitude: $0.location.longitude)
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

    fileprivate class Coordinator: NSObject, MKMapViewDelegate {
        private final let parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        fileprivate final func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
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
