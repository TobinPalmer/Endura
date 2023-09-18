import Combine
import Foundation
import HealthKit
import MapKit
import SwiftUI

private struct ColoredPolyline: Identifiable {
    var id = UUID()
    var color: UIColor
    var polyline: MKPolyline
}

private class MapViewContainer: ObservableObject {
    @Published var mapView: MKMapView = .init()

    func updateAnnotation(position: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = position
        mapView.addAnnotation(annotation)
    }

    func removeAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
    }
}

struct ActivityMap: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    private var routeData: [RouteData]
    private var bottomSpace: Bool
    @State private var mapViewContainer = MapViewContainer()

    public init(_ route: [RouteData], bottomSpace: Bool = false) {
        routeData = route
        self.bottomSpace = bottomSpace
    }

    var body: some View {
        if routeData.isEmpty {
            EmptyView()
        } else {
            VStack {
                VStack {
                    MapView(mapViewContainer: mapViewContainer, routeData: routeData)
                        .frame(height: 300)
                        .onChange(of: activityViewModel.analysisPosition) { timePosition in
                            if let timePosition = timePosition {
                                if let location = activityViewModel.getAnalysisLocation(for: timePosition) {
                                    mapViewContainer.updateAnnotation(position: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                                }
                            } else {
                                mapViewContainer.removeAnnotation()
                            }
                        }
                }
            }
        }
    }
}

private struct MapView: UIViewRepresentable {
    @ObservedObject private var mapViewContainer: MapViewContainer
    private let routeData: [RouteData]

    private let averagePace: Double

    fileprivate init(mapViewContainer: MapViewContainer, routeData: [RouteData]) {
        self.mapViewContainer = mapViewContainer
        self.routeData = routeData

        averagePace = routeData.reduce(0.0) { pace, data in
            pace + 26.8224 / data.pace
        } / Double(routeData.count)

        print("AVE PACE", averagePace)
    }

    fileprivate func colorForPace(_ pace: Double) -> UIColor {
        var pace = 26.8224 / pace
        let maxPace = averagePace * 1.4
        let minPace = 0.0
        let maxHue = 0.7
        pace = max(min(pace, maxPace), minPace)

        var roundedPace = 0.0
        if pace > 7.0 {
            roundedPace = pace.rounded()
        } else {
            roundedPace = (pace * 2).rounded() / 2
        }
        let hue = maxHue - (roundedPace * (maxHue / maxPace))

        if hue > 1 || hue < 0 {
            return UIColor(hue: 0.0, saturation: 1.0, lightness: 0.5, alpha: 1.0)
        }

        return UIColor(hue: CGFloat(hue), saturation: 1.0, lightness: 0.5, alpha: 1.0)
    }

    fileprivate func makeUIView(context: Context) -> MKMapView {
        mapViewContainer.mapView.delegate = context.coordinator
        return mapViewContainer.mapView
    }

    fileprivate func updateUIView(_ uiView: MKMapView, context _: Context) {
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

            let coordinates = routeData.map { data in
                CLLocationCoordinate2D(latitude: data.location.latitude, longitude: data.location.longitude)
            }
            let region = MKCoordinateRegion(coordinates: coordinates)
            uiView.setRegion(region, animated: false)
        }
    }

    fileprivate func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

private class Coordinator: NSObject, MKMapViewDelegate {
    private final let parent: MapView

    init(_ parent: MapView) {
        self.parent = parent
    }

    fileprivate final func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = polyline.color
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
}
