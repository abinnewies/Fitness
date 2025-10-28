//
//  HealthKitSampleManager.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import Foundation

struct Sample {
  let value: Double
  let date: Date
}

enum SampleStride {
  case hour(Int)

  var calendarComponent: Calendar.Component {
    switch self {
    case .hour:
      return .hour
    }
  }

  var dateComponents: DateComponents {
    switch self {
    case let .hour(hour):
      DateComponents(hour: hour)
    }
  }

  var value: Int {
    switch self {
    case let .hour(hour):
      hour
    }
  }
}

class HealthKitSampleManager {
  private let healthKitManager: HealthKitManager

  init(healthKitManager: HealthKitManager) {
    self.healthKitManager = healthKitManager
  }

  func fetchSamples(
    metric: HealthMetric,
    from: Date,
    to: Date,
    stride: SampleStride
  ) async throws -> [Int: Double] {
    switch metric {
    case .heartRate:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .heartRate,
        from: from,
        to: to,
        statisticsType: .average,
        interval: stride.dateComponents
      )
    case .hrv:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .hrv,
        from: from,
        to: to,
        statisticsType: .average,
        interval: stride.dateComponents
      )
    case .restingHeartRate:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .restingHeartRate,
        from: from,
        to: to,
        statisticsType: .average,
        interval: stride.dateComponents
      )
    case .stepCount:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .stepCount,
        from: from,
        to: to,
        statisticsType: .cumulativeSum,
        interval: stride.dateComponents
      )
    case .caloriesBurned:
      let activeEnergySamples = try await healthKitManager.fetchStatisticsCollection(
        type: .activeEnergyBurned,
        from: from,
        to: to,
        statisticsType: .cumulativeSum,
        interval: stride.dateComponents
      )
      let basalEnergySamples = try await healthKitManager.fetchStatisticsCollection(
        type: .basalEnergyBurned,
        from: from,
        to: to,
        statisticsType: .cumulativeSum,
        interval: stride.dateComponents
      )

      var caloriesBurned: [Int: Double] = [:]
      for item in Set(activeEnergySamples.keys).union(Set(basalEnergySamples.keys)) {
        caloriesBurned[item] = (activeEnergySamples[item] ?? 0) + (basalEnergySamples[item] ?? 0)
      }
      return caloriesBurned
    }
  }
}
