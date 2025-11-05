//
//  SmallCaloriesGraph.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

import SwiftUI

struct SmallCaloriesGraph: View {
  let from: Date
  let to: Date
  let currentDate: Date
  let healthKitManager: HealthKitManager
  let stride: SampleStride

  private let hourlyStride = 1

  @State private var chartData: [(x: Date, y1: Double?, y2: Double?)] = []
  @State private var showChart = false

  var body: some View {
    Group {
      StackedBarChart(
        from: from,
        to: to,
        bottomColor: Color.basalCaloriesBurned,
        topColor: Color.caloriesBurned,
        chartData: chartData
      )
      .opacity(showChart ? 1 : 0)
      .animation(.easeIn(duration: 0.25), value: showChart)
    }
    .task(id: currentDate) {
      do {
        let basalEnergyBurnedSamples = try await healthKitManager.fetchStatisticsCollection(
          type: .basalEnergyBurned,
          from: from,
          to: to,
          statisticsType: .cumulativeSum,
          interval: stride.dateComponents
        )
        let activeEnergyBurnedSamples = try await healthKitManager.fetchStatisticsCollection(
          type: .activeEnergyBurned,
          from: from,
          to: to,
          statisticsType: .cumulativeSum,
          interval: stride.dateComponents
        )

        var combinedData: [Int: (y1: Double?, y2: Double?)] = [:]
        for (key, value) in basalEnergyBurnedSamples {
          combinedData[key, default: (y1: nil, y2: nil)].y1 = value
        }
        for (key, value) in activeEnergyBurnedSamples {
          combinedData[key, default: (y1: nil, y2: nil)].y2 = value
        }

        withAnimation {
          chartData = combinedData.map { key, value in
            (
              x: from.addingTimeInterval(TimeInterval(key) * stride.timeInterval),
              y1: value.y1,
              y2: value.y2
            )
          }.sorted(by: { $0.x < $1.x })

          showChart = true
        }
      } catch {}
    }
  }
}
