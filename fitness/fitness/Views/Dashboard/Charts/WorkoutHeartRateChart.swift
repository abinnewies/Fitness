//
//  WorkoutHeartRateChart.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/31/25.
//

import SwiftUI

struct WorkoutHeartRateChart: View {
  let from: Date
  let to: Date
  let currentDate: Date
  let healthKitManager: HealthKitManager
  let stride: SampleStride

  @State private var chartData: [HeartRateChartDataPoint] = []
  @State private var averageHeartRate: Double?
  @State private var showChart = false

  var body: some View {
    Group {
      HeartRateChart(
        from: from,
        to: to,
        chartData: chartData,
        colorStyle: .zoneBased(.heartRate),
        dateStyle: .minute,
        referenceY: averageHeartRate,
        displayMinMaxValues: true
      )
    }
    .opacity(showChart ? 1 : 0)
    .animation(.easeInOut(duration: 0.3), value: showChart)
    .task(id: currentDate) {
      do {
        let chartDataManager = ChartDataManager(healthKitManager: healthKitManager)
        let chartData = try await chartDataManager.fetchHeartRateData(from: from, to: to, stride: stride)
        let averageHeartRate = try? await healthKitManager.fetchStatistics(
          type: .average,
          quantityType: .heartRate,
          from: from,
          to: to
        )

        withAnimation {
          self.chartData = chartData
          self.averageHeartRate = averageHeartRate
          showChart = true
        }
      } catch {}
    }
  }
}
