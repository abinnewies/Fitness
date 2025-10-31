//
//  HealthKitExtensions.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import HealthKit

extension HKWorkout {
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

extension HKWorkout: @retroactive Identifiable {
  public var id: String {
    uuid.uuidString
  }
}
