//
//  HKWorkout+Metrics.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/31/25.
//

import HealthKit

extension HKWorkout {
  var averageHeartRate: Int? {
    guard let quantity = statistics(for: HKQuantityType(.heartRate))?.averageQuantity() else {
      return nil
    }
    return Int(quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
  }

  var distanceMeters: Double? {
    totalDistance?.doubleValue(for: .meter())
  }

  var elevationAscendedMeters: Double? {
    guard let quantity = metadata?[HKMetadataKeyElevationAscended] as? HKQuantity else {
      return nil
    }
    return quantity.doubleValue(for: .meter())
  }
}
