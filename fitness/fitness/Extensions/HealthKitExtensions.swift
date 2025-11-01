//
//  HealthKitExtensions.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import HealthKit

extension HKWorkout: @retroactive Identifiable {
  public var id: String {
    uuid.uuidString
  }
}
