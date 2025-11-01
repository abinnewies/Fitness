//
//  ChartDataManager.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/31/25.
//

import Foundation

struct HeartRateChartDataPoint {
  let date: Date
  let minHeartRate: Double?
  let maxHeartRate: Double?
}

class ChartDataManager {
  private let sampleManager: HealthKitSampleManager

  init(healthKitManager: HealthKitManager) {
    sampleManager = HealthKitSampleManager(healthKitManager: healthKitManager)
  }

  func fetchHeartRateData(from: Date, to: Date, stride: SampleStride) async throws -> [HeartRateChartDataPoint] {
    let minSamples = try await sampleManager.fetchSamples(metric: .minHeartRate, from: from, to: to, stride: stride)
    let maxSamples = try await sampleManager.fetchSamples(metric: .maxHeartRate, from: from, to: to, stride: stride)

    var combinedData: [Int: (minHeartRate: Double?, maxHeartRate: Double?)] = [:]
    for (key, value) in minSamples {
      combinedData[key, default: (minHeartRate: nil, maxHeartRate: nil)].minHeartRate = value
    }
    for (key, value) in maxSamples {
      combinedData[key, default: (minHeartRate: nil, maxHeartRate: nil)].maxHeartRate = value
    }

    return combinedData.map { key, value in
      HeartRateChartDataPoint(
        date: from.addingTimeInterval(TimeInterval(key) * stride.timeInterval),
        minHeartRate: value.minHeartRate,
        maxHeartRate: value.maxHeartRate
      )
    }.sorted(by: { $0.date < $1.date })
  }
}
