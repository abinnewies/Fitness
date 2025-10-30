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

  var dateComponents: DateComponents {
    switch self {
    case let .hour(hour):
      DateComponents(hour: hour)
    }
  }

  var timeInterval: TimeInterval {
    switch self {
    case let .hour(hour):
      TimeInterval(hour) * 3600
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
    case .minHeartRate:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .heartRate,
        from: from,
        to: to,
        statisticsType: .min,
        interval: stride.dateComponents
      )
    case .maxHeartRate:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .heartRate,
        from: from,
        to: to,
        statisticsType: .max,
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
    case .activeCaloriesBurned:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .activeEnergyBurned,
        from: from,
        to: to,
        statisticsType: .cumulativeSum,
        interval: stride.dateComponents
      )
    case .basalCaloriesBurned:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .basalEnergyBurned,
        from: from,
        to: to,
        statisticsType: .cumulativeSum,
        interval: stride.dateComponents
      )
    }
  }
}
