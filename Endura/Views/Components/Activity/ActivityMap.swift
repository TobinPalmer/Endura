//
// Created by Tobin Palmer on 7/22/23.
//

import Foundation
import MapKit
import SwiftUI
import HealthKit
import Combine

struct ColoredPolyline: Identifiable {
    var id = UUID()
    var color: UIColor
    var polyline: MKPolyline
}

class MapViewContainer: ObservableObject {
    @Published var mapView: MKMapView = MKMapView()

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

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}


public struct ActivityMap: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @State private var routeData: [RouteData]
    @State private var mapViewContainer = MapViewContainer()

    public init(_ route: [RouteData]) {
        routeData = route
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack {
                if !routeData.isEmpty {
                    let map = MapView(mapViewContainer: mapViewContainer, routeData: $routeData)
                        .frame(height: 300)
                        .onChange(of: activityViewModel.analysisPosition) { timePosition in
                            if let timePosition = timePosition {
                                if let position = routeData.first(where: { data in
                                    data.timestamp > timePosition
                                }) {
                                    mapViewContainer.updateAnnotation(position: CLLocationCoordinate2D(latitude: position.location.latitude, longitude: position.location.longitude))
                                }
                            } else {
                                mapViewContainer.removeAnnotation()
                            }
                        }

                    map

                    Button("Take Snapshot") {
                        let image = map
                            .takeScreenshot(origin: geometry.frame(in: .global).origin, size: geometry.size)
                        print(image)

                        //save image to documents
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileName = "image.png"
                        let fileURL = documentsDirectory.appendingPathComponent(fileName)
                        if let data = image.pngData() {
                            try? data.write(to: fileURL)
                            print("Saved", fileURL)
                        }
                    }
                } else {
                    Text("No route data available")
                }
            }
        }
    }
}

fileprivate struct MapView: UIViewRepresentable {
    @ObservedObject var mapViewContainer: MapViewContainer
    @Binding var routeData: [RouteData]

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

    fileprivate func makeUIView(context: Context) -> MKMapView {
        mapViewContainer.mapView.delegate = context.coordinator
        return mapViewContainer.mapView
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
