//
// Created by Tobin Palmer on 7/18/23.
//

import Foundation
import HealthKit

public struct HealthKitUtils {
    private static let healthStore = HKHealthStore()

    public static func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(), HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Authorization request failed: \(error.localizedDescription)")
                return
            }
        }
    }

    public static func getListOfWorkouts(limitTo: Int = 1, completion: @escaping (Result<[HKWorkout?], Error>) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: nil,
            limit: limitTo,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { (query, samples, error) in
            if let error = error {
                completion(.failure(error))
            } else if let workouts = samples as? [HKWorkout?] {
                completion(.success(workouts))
            } else {
                completion(.success([]))
            }
        }

        healthStore.execute(query)
    }

}
