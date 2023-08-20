import Foundation
import MapKit

extension CLLocation: Identifiable, Encodable {
    public var id: String {
        UUID().uuidString
    }

    ///    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country: String?, _ error: Error?) -> ()) {
    ///        CLGeocoder().reverseGeocodeLocation(self) {
    ///            completion($0?.first?.locality, $0?.first?.country, $1)
    ///        }
    ///    }
    func fetchCityAndCountry() async throws -> (String?, String?) {
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(self)
        let city = placemarks.first?.locality
        let country = placemarks.first?.country
        return (city, country)
    }

    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case horizontalAccuracy
        case verticalAccuracy
        case speed
        case course
        case timestamp
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(course, forKey: .course)
        try container.encode(timestamp, forKey: .timestamp)
    }
}
