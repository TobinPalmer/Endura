//
// Created by Brandon Kirbyson on 7/24/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct ActivityUtils {

    public static func getActivityRouteData(id: String) async -> ActivityRouteData {
        print("Getting activity route data...", id)
        do {
            let routeData = try await Firestore.firestore().collection("activities").document(id).collection("data").document("data").getDocument(as: ActivityRouteData.self)
            return routeData;
        } catch {
            print("Error getting activity route data: \(error)")
            return ActivityRouteData(routeData: [], graphData: [], graphInterval: 0)
        }
    }
}