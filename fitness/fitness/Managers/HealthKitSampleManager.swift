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
  case minute(Int)
  case timeInterval(TimeInterval)

  var dateComponents: DateComponents {
    switch self {
    case let .hour(hour):
      return DateComponents(hour: hour)
    case let .minute(minute):
      return DateComponents(minute: minute)
    case let .timeInterval(timeInterval):
      let hour = Int((timeInterval / 3600).truncatingRemainder(dividingBy: 3600))
      let minute = Int((timeInterval / 60).truncatingRemainder(dividingBy: 60))
      let second = Int(timeInterval.truncatingRemainder(dividingBy: 60))
      return DateComponents(hour: hour, minute: minute, second: second)
    }
  }

  var timeInterval: TimeInterval {
    switch self {
    case let .hour(hour):
      TimeInterval(hour) * 3600
    case let .minute(minute):
      TimeInterval(minute) * 60
    case let .timeInterval(timeInterval):
      timeInterval
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
    case .averageHeartRate, .heartRate:
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
