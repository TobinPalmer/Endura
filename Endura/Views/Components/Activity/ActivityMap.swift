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
            var previousCoordinate: CLLocationCoordinate2D? = nil
            for data in routeData {
                let currentCoordinate = CLLocationCoordinate2D(latitude: data.location.latitude, longitude: data.location.longitude)

                if let previous = previousCoordinate {
                    let paceColor = colorForPace(data.pace)
                    let segment = ColorPolyline(coordinates: [previous, currentCoordinate], count: 2, color: paceColor)
                    uiView.addOverlay(segment)
                }

                previousCoordinate = currentCoordinate
            }

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

    fileprivate func colorForPace(_ pace: Double) -> UIColor {
//        let clampedPace = min(max(pace, 0), 5)
//        let ratio = clampedPace / 5
//        let paceColor = UIColor(red: CGFloat(ratio), green: CGFloat(1 - ratio), blue: 0.0, alpha: 1.0)
//        return paceColor
        print(pace)
        switch pace {
        case let x where x < 2.0:
            return UIColor.green
        case let x where x < 2.5:
            return UIColor.green
        case let x where x < 3.0:
            return UIColor.green
        case let x where x < 3.5:
            return UIColor.green
        case let x where x < 3.7:
            return UIColor.green
        case let x where x < 4.0:
            return UIColor.green
        case let x where x < 4.25:
            return UIColor.green
        case let x where x < 4.5:
            return UIColor.orange
        default:
            return UIColor.red
        }
    }
}

fileprivate class Coordinator: NSObject, MKMapViewDelegate {
    private final let parent: MapView

    init(_ parent: MapView) {
        self.parent = parent
    }

    fileprivate final func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let segment = overlay as? ColorPolyline {
            let renderer = MKPolylineRenderer(polyline: segment)
            renderer.strokeColor = segment.color
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
}

fileprivate class ColorPolyline: MKPolyline {
    var color: UIColor?

    convenience init(coordinates: [CLLocationCoordinate2D], count: Int, color: UIColor) {
        self.init(coordinates: coordinates, count: count)
        self.color = color
    }
}
