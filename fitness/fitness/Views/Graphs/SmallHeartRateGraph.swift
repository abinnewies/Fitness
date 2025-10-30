//
//  SmallHeartRateGraph.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

import SwiftUI

struct SmallHeartRateGraph: View {
  let from: Date
  let to: Date
  let currentDate: Date
  let healthKitManager: HealthKitManager
  let stride: SampleStride

  private let hourlyStride = 1

  @State private var chartData: [(x: Date, minY: Double?, maxY: Double?)] = []
  @State private var restingHeartRate: Double?
  @State private var showChart = false

  var body: some View {
    Group {
      AreaChart(from: from, to: to, chartData: chartData, referenceY: restingHeartRate)
    }
    .task(id: currentDate) {
      do {
        let sampleManager = HealthKitSampleManager(healthKitManager: healthKitManager)
        let minSamples = try await sampleManager.fetchSamples(metric: .minHeartRate, from: from, to: to, stride: stride)
        let maxSamples = try await sampleManager.fetchSamples(metric: .maxHeartRate, from: from, to: to, stride: stride)
        restingHeartRate = try? await healthKitManager.fetchStatistics(
          type: .average,
          quantityType: .restingHeartRate,
          from: from,
          to: to
        )

        var combinedData: [Int: (minY: Double?, maxY: Double?)] = [:]
        for (key, value) in minSamples {
          combinedData[key, default: (minY: nil, maxY: nil)].minY = value
        }
        for (key, value) in maxSamples {
          combinedData[key, default: (minY: nil, maxY: nil)].maxY = value
        }

        chartData = combinedData.map { key, value in
          (x: from.addingTimeInterval(TimeInterval(key) * stride.timeInterval), minY: value.minY, maxY: value.maxY)
        }.sorted(by: { $0.x < $1.x })

        withAnimation {
          showChart = true
        }
      } catch {}
    }
  }
}
