//
//  HealthMetric.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

enum HealthMetric {
  case caloriesBurned
  case heartRate
  case hrv
  case restingHeartRate
  case stepCount

  var cumulative: Bool {
    switch self {
    case .caloriesBurned, .stepCount:
      true
    case .heartRate, .hrv, .restingHeartRate:
      false
    }
  }
}
