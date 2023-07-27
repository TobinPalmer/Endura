//
// Created by Tobin Palmer on 7/22/23.
//

import Foundation
import MapKit
import SwiftUI
import HealthKit

public struct ActivityMap: View {
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
            var coordinates: [CLLocationCoordinate2D] = []
            for data in routeData {
                let currentCoordinate = CLLocationCoordinate2D(latitude: data.location.latitude, longitude: data.location.longitude)
                coordinates.append(currentCoordinate)
            }

            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            uiView.addOverlay(polyline)

            if let first = routeData.first, let last = routeData.last {
                let firstCordinate = CLLocationCoordinate2D(latitude: first.location.latitude, longitude: first.location.longitude)
                let lastCordinate = CLLocationCoordinate2D(latitude: last.location.latitude, longitude: last.location.longitude)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (firstCordinate.latitude + lastCordinate.latitude) / 2, longitude: (firstCordinate.longitude + lastCordinate.longitude) / 2), span: MKCoordinateSpan(latitudeDelta: abs(firstCordinate.latitude - lastCordinate.latitude), longitudeDelta: abs(firstCordinate.longitude - lastCordinate.longitude)))
                uiView.setRegion(region, animated: false)
            }
        }
    }

    fileprivate func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

fileprivate class Coordinator: NSObject, MKMapViewDelegate {
    private final let parent: MapView

    init(_ parent: MapView) {
        self.parent = parent
    }

    fileprivate final func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
}
