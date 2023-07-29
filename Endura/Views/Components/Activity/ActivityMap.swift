//
// Created by Tobin Palmer on 7/22/23.
//

import Foundation
import MapKit
import SwiftUI
import HealthKit

struct ColoredPolyline: Identifiable {
    var id = UUID()
    var color: UIColor
    var polyline: MKPolyline
}

public struct ActivityMap: View {
    @State private var routeData: [RouteData];

    public init(_ route: [RouteData]) {
        routeData = route
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

        var overlaysToAdd = [ColoredPolyline]()
        var currentPolylineCoordinates = [CLLocationCoordinate2D]()
        var currentPaceColor: UIColor = .green

        if !routeData.isEmpty {
            for data in routeData {
                let paceColor = colorForPace(data.pace)
                let currentCoordinate = CLLocationCoordinate2D(latitude: data.location.latitude, longitude: data.location.longitude)

                if paceColor != currentPaceColor {
                    if !currentPolylineCoordinates.isEmpty {
                        currentPolylineCoordinates.append(currentCoordinate) // Add the start point of the next polyline to the current one

                        let polyline = MKPolyline(coordinates: currentPolylineCoordinates, count: currentPolylineCoordinates.count)

                        overlaysToAdd.append(ColoredPolyline(color: paceColor, polyline: polyline))
                        currentPolylineCoordinates = [currentCoordinate] // Start new polyline with the color changing point
                    }
                    currentPaceColor = paceColor
                } else {
                    currentPolylineCoordinates.append(currentCoordinate)
                }
            }

            if !currentPolylineCoordinates.isEmpty {
                let polyline = MKPolyline(coordinates: currentPolylineCoordinates, count: currentPolylineCoordinates.count)
                var color = UIColor.yellow

                color = currentPaceColor

                overlaysToAdd.append(ColoredPolyline(color: color, polyline: polyline))
            }


            // add all prepared overlays
            for overlay in overlaysToAdd {
                overlay.polyline.color = overlay.color
                uiView.addOverlay(overlay.polyline)
            }

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
    var pace = 26.8224 / pace
    let maxPace = 10.0
    let minPace = 0.0
    let maxHue = 0.7
    pace = max(min(pace, maxPace), minPace)
    var roundedPace: Double = 0.0
    if pace > 7.0 {
        roundedPace = (pace).rounded()
    } else {
        roundedPace = (pace * 2).rounded() / 2
    }
    //Take the rounded pace and convert it to a percentage of the max pace in the hue format which is 0...1
    let hue = maxHue - (roundedPace * (maxHue / (maxPace)))
    if (hue > 1 || hue < 0) {
        return UIColor(hue: 0.0, saturation: 1.0, lightness: 0.5, alpha: 1.0)
    }
    return UIColor(hue: CGFloat(hue), saturation: 1.0, lightness: 0.5, alpha: 1.0)
}

extension UIColor {
    convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        precondition(0...1 ~= hue &&
            0...1 ~= saturation &&
            0...1 ~= lightness &&
            0...1 ~= alpha, "input range is out of range 0...1")

        var newSaturation: CGFloat = 0.0

        let brightness = lightness + saturation * min(lightness, 1 - lightness)

        if brightness == 0 {
            newSaturation = 0.0
        } else {
            newSaturation = 2 * (1 - lightness / brightness)
        }

        self.init(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
}
