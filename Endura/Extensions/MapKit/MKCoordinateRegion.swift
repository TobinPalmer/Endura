import Foundation
import MapKit

public extension MKCoordinateRegion {
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
