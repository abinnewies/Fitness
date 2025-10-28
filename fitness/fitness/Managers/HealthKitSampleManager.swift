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
    let calendar = Calendar.current

    let allSamples: [Sample]
    switch metric {
    case .heartRate:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .heartRate,
        from: from,
        to: to,
        interval: stride.dateComponents
      )
    case .hrv:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .hrv,
        from: from,
        to: to,
        interval: stride.dateComponents
      )
    case .restingHeartRate:
      return try await healthKitManager.fetchStatisticsCollection(
        type: .restingHeartRate,
        from: from,
        to: to,
        interval: stride.dateComponents
      )
    case .stepCount:
      allSamples = try await healthKitManager.fetchSamples(type: .stepCount, from: from, to: to)
    case .caloriesBurned:
      let activeEnergySamples = try await healthKitManager.fetchSamples(type: .activeEnergyBurned, from: from, to: to)
      let basalEnergySamples = try await healthKitManager.fetchSamples(type: .basalEnergyBurned, from: from, to: to)
      allSamples = activeEnergySamples + basalEnergySamples
    }

    var totals: [Int: Double] = [:]
    for sample in allSamples {
      let hour = calendar.component(stride.calendarComponent, from: sample.date) / stride.value
      if let existing = totals[hour] {
        totals[hour] = existing + sample.value
      } else {
        totals[hour] = sample.value
      }
    }

    return totals
  }
}
