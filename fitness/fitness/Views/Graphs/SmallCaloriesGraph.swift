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
  let healthKitManager: HealthKitManager
  let stride: SampleStride

  private let hourlyStride = 1

  @State private var chartData: [(x: Date, y: Double?)] = []
  @State private var showChart = false

  var body: some View {
    Group {
      BarChart(from: from, to: to, chartData: chartData)
        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        .opacity(showChart ? 1 : 0)
        .animation(.easeIn(duration: 0.25), value: showChart)
    }
    .task(id: from ... to) {
      do {
        let sampleManager = HealthKitSampleManager(healthKitManager: healthKitManager)
        let samples = try await sampleManager.fetchSamples(metric: .caloriesBurned, from: from, to: to, stride: stride)

        chartData = samples.map { key, value in
          (x: from.addingTimeInterval(TimeInterval(key) * stride.timeInterval), y: value)
        }.sorted(by: { $0.x < $1.x })

        withAnimation {
          showChart = true
        }
      } catch {}
    }
  }
}
