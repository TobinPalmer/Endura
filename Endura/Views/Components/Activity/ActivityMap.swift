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

        var redPolylineCoordinates = [CLLocationCoordinate2D]()
        var greenPolylineCoordinates = [CLLocationCoordinate2D]()
        var yellowPolylineCoordinates = [CLLocationCoordinate2D]()

        if !routeData.isEmpty {
            for data in routeData {
                let currentCoordinate = CLLocationCoordinate2D(latitude: data.location.latitude, longitude: data.location.longitude)

                let paceColor = colorForPace(data.pace)
                if paceColor == .red {
                    redPolylineCoordinates.append(currentCoordinate)
                } else if paceColor == .green {
                    greenPolylineCoordinates.append(currentCoordinate)
                } else if paceColor == .yellow {
                    yellowPolylineCoordinates.append(currentCoordinate)
                }
            }

            let redPolyline = MKPolyline(coordinates: redPolylineCoordinates, count: redPolylineCoordinates.count)
            redPolyline.color = .red
            uiView.addOverlay(redPolyline)

            let greenPolyline = MKPolyline(coordinates: greenPolylineCoordinates, count: greenPolylineCoordinates.count)
            greenPolyline.color = .green
            uiView.addOverlay(greenPolyline)

            let yellowPolyline = MKPolyline(coordinates: yellowPolylineCoordinates, count: yellowPolylineCoordinates.count)
            yellowPolyline.color = .yellow
            uiView.addOverlay(yellowPolyline)

            print("Total overlays: \(uiView.overlays.count)")

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
            renderer.strokeColor = polyline.color
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
}

fileprivate extension MKPolyline {
    var color: UIColor {
        get { objc_getAssociatedObject(self, &colorKey) as? UIColor ?? UIColor.black }
        set { objc_setAssociatedObject(self, &colorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private var colorKey: UInt8 = 0

fileprivate func colorForPace(_ pace: Double) -> UIColor {
    switch pace {
    case let p where p < 3.0: return .green
    case let p where p < 5.0: return .yellow
    default: return .red
    }
}
