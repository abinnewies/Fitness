//
//  SmallSleepChart.swift
//  Fitness
//
//  Created by Andreas Binnewies on 11/4/25.
//

import HealthKit
import SwiftUI

struct SmallSleepChart: View {
  let from: Date
  let to: Date
  let currentDate: Date
  let healthKitManager: HealthKitManager

  @State private var chartData: [HKCategorySample] = []
  @State private var showChart = false

  var body: some View {
    Group {
      SleepChartView(healthKitSamples: chartData)
    }
    .opacity(showChart ? 1 : 0)
    .animation(.easeInOut(duration: 0.3), value: showChart)
    .task(id: currentDate) {
      do {
        let halfDaySeconds: TimeInterval = 43200
        let chartData = try await healthKitManager.fetchSamples(
          from: from - halfDaySeconds,
          to: to,
          sampleType: HKCategoryType(.sleepAnalysis)
        )
        withAnimation {
          self.chartData = (chartData as? [HKCategorySample]) ?? []
          showChart = !self.chartData.isEmpty
        }
      } catch {}
    }
  }
}
