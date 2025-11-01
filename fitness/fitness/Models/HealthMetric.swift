//
//  HealthMetric.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import SwiftUI

enum HealthMetric: MetricRepresentable {
  case activeCaloriesBurned
  case averageHeartRate
  case basalCaloriesBurned
  case heartRate
  case hrv
  case minHeartRate
  case maxHeartRate
  case restingHeartRate
  case stepCount

  var title: String {
    switch self {
    case .activeCaloriesBurned:
      return "Active Calories"
    case .averageHeartRate:
      return "Avg Heart Rate"
    case .basalCaloriesBurned:
      return "Basal Calories"
    case .heartRate:
      return "Heart Rate"
    case .hrv:
      return "HRV"
    case .minHeartRate:
      return "Min Heart Rate"
    case .maxHeartRate:
      return "max Heart Rate"
    case .restingHeartRate:
      return "Resting Heart Rate"
    case .stepCount:
      return "Step Count"
    }
  }

  var symbol: SFSymbolName {
    switch self {
    case .activeCaloriesBurned:
      .flameFill
    case .averageHeartRate:
      .heartFill
    case .basalCaloriesBurned:
      .flameFill
    case .heartRate:
      .heartFill
    case .hrv:
      .heartFill
    case .minHeartRate:
      .heartFill
    case .maxHeartRate:
      .heartFill
    case .restingHeartRate:
      .heartFill
    case .stepCount:
      .shoeprintsFill
    }
  }

  var color: Color {
    switch self {
    case .activeCaloriesBurned:
      .caloriesBurned
    case .averageHeartRate:
      .heartRate
    case .basalCaloriesBurned:
      .basalCaloriesBurned
    case .heartRate:
      .heartRate
    case .hrv:
      .heartRate
    case .minHeartRate:
      .heartRate
    case .maxHeartRate:
      .heartRate
    case .restingHeartRate:
      .heartRate
    case .stepCount:
      .stepCount
    }
  }
}
