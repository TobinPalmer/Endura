//
// Created by Tobin Palmer on 7/22/23.
//

import Foundation
import MapKit
import SwiftUI
import HealthKit

let lightGreen = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
let darkGreen = UIColor(red: 0.0, green: 0.3, blue: 0.0, alpha: 1.0)

struct ColoredPolyline: Identifiable {
    var id = UUID()
    var color: UIColor
    var polyline: MKPolyline
}

enum PaceColor {
    case red
    case lightGreen
    case green
    case darkGreen
    case yellow
    case none
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
        var currentPaceColor: PaceColor = .none

        if !routeData.isEmpty {

//            for data in routeData {
//
//                let paceColor = colorForPace(data.pace)
//                let currentCoordinate = CLLocationCoordinate2D(latitude: data.location.latitude, longitude: data.location.longitude)
//
//                if paceColor != currentPaceColor {
//                    if !currentPolylineCoordinates.isEmpty {
//                        let polyline = MKPolyline(coordinates: currentPolylineCoordinates, count: currentPolylineCoordinates.count)
//                        var color = UIColor.black
//                        switch currentPaceColor {
//                        case .red: color = .red
//                        case .lightGreen: color = lightGreen
//                        case .green: color = .green
//                        case .darkGreen: color = darkGreen
//                        case .yellow: color = .yellow
//                        default:
//                            break
//                        }
//                        overlaysToAdd.append(ColoredPolyline(color: color, polyline: polyline))
//                        currentPolylineCoordinates.removeAll()
//                    }
//                    currentPaceColor = paceColor
//                }
//
//                currentPolylineCoordinates.append(currentCoordinate)
//
//            }
//
//            if !currentPolylineCoordinates.isEmpty {
//                let polyline = MKPolyline(coordinates: currentPolylineCoordinates, count: currentPolylineCoordinates.count)
//                var color = UIColor.black
//                switch currentPaceColor {
//                case .red: color = .red
//                case .lightGreen: color = lightGreen
//                case .green: color = .green
//                case .darkGreen: color = darkGreen
//                case .yellow: color = .yellow
//                default:
//                    break
//                }
//                overlaysToAdd.append(ColoredPolyline(color: color, polyline: polyline))
//            }

            for data in routeData {
                let paceColor = colorForPace(data.pace)
                let currentCoordinate = CLLocationCoordinate2D(latitude: data.location.latitude, longitude: data.location.longitude)

                if paceColor != currentPaceColor {
                    if !currentPolylineCoordinates.isEmpty {
                        currentPolylineCoordinates.append(currentCoordinate) // Add the start point of the next polyline to the current one

                        let polyline = MKPolyline(coordinates: currentPolylineCoordinates, count: currentPolylineCoordinates.count)
                        var color = UIColor.black

                        switch currentPaceColor {
                        case .red: color = .red
                        case .lightGreen: color = lightGreen
                        case .green: color = .green
                        case .darkGreen: color = darkGreen
                        case .yellow: color = .yellow
                        default:
                            break
                        }

                        overlaysToAdd.append(ColoredPolyline(color: color, polyline: polyline))
                        currentPolylineCoordinates = [currentCoordinate] // Start new polyline with the color changing point
                    }
                    currentPaceColor = paceColor
                } else {
                    currentPolylineCoordinates.append(currentCoordinate)
                }
            }

            if !currentPolylineCoordinates.isEmpty {
                let polyline = MKPolyline(coordinates: currentPolylineCoordinates, count: currentPolylineCoordinates.count)
                var color = UIColor.black

                switch currentPaceColor {
                case .red: color = .red
                case .lightGreen: color = lightGreen
                case .green: color = .green
                case .darkGreen: color = darkGreen
                case .yellow: color = .yellow
                default:
                    break
                }

                overlaysToAdd.append(ColoredPolyline(color: color, polyline: polyline))
            }


            // add all prepared overlays
            for overlay in overlaysToAdd {
                var color: UIColor = .black
                print("overlay color", overlay)
                switch overlay.color {
                case .red: color = .red
                case lightGreen: color = lightGreen
                case .green: color = .green
                case darkGreen: color = darkGreen
                case .yellow: color = .yellow
                default:
                    break
                }

                overlay.polyline.color = color
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

fileprivate func colorForPace(_ pace: Double) -> PaceColor {
    // Convert pace to min/mile
    let pace = 26.8224 / pace
    print(pace)
    switch pace {
    case let p where p < 5.0 && p > 0.0: return .red
    case let p where p < 6.0 && p > 5.0: return .lightGreen
    case let p where p < 7.0 && p > 6.0: return .green
    case let p where p < 9.0 && p > 7.0: return .yellow
    case let p where p < 10.0 && p > 9.0: return .red

    default: return .red
    }
}

//fileprivate func colorForPace(_ pace: Double) -> UIColor {
//    switch pace {
//    case let p where p < 3.0: return .green
//    case let p where p < 5.0: return .yellow
//    default: return .red
//    }
//}
