//
//  SmallStepsGraph.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

import SwiftUI

struct SmallStepsGraph: View {
  let from: Date
  let to: Date
  let currentDate: Date
  let healthKitManager: HealthKitManager
  let stride: SampleStride

  private let hourlyStride = 1

  @State private var chartData: [(x: Date, y: Double?)] = []
  @State private var showChart = false

  var body: some View {
    Group {
      BarChart(from: from, to: to, color: Color.stepCount, chartData: chartData)
        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        .opacity(showChart ? 1 : 0)
        .animation(.easeIn(duration: 0.25), value: showChart)
    }
    .task(id: currentDate) {
      do {
        let sampleManager = HealthKitSampleManager(healthKitManager: healthKitManager)
        let samples = try await sampleManager.fetchSamples(metric: .stepCount, from: from, to: to, stride: stride)

        withAnimation {
          chartData = samples.map { key, value in
            (x: from.addingTimeInterval(TimeInterval(key) * stride.timeInterval), y: value)
          }.sorted(by: { $0.x < $1.x })
          showChart = true
        }
      } catch {}
    }
  }
}
