//
//  SmallHeartRateChart.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

import SwiftUI

struct SmallHeartRateChart: View {
  let from: Date
  let to: Date
  let currentDate: Date
  let healthKitManager: HealthKitManager
  let stride: SampleStride

  @State private var chartData: [HeartRateChartDataPoint] = []
  @State private var restingHeartRate: Double?
  @State private var showChart = false

  var body: some View {
    Group {
      HeartRateChart(
        from: from,
        to: to,
        chartData: chartData,
        colorStyle: .singleColor(.heartRate),
        dateStyle: .hour,
        referenceY: restingHeartRate,
        displayMinMaxValues: false
      )
      .frame(height: 60)
    }
    .opacity(showChart ? 1 : 0)
    .animation(.easeInOut(duration: 0.3), value: showChart)
    .task(id: currentDate) {
      do {
        let chartDataManager = ChartDataManager(healthKitManager: healthKitManager)
        let chartData = try await chartDataManager.fetchHeartRateData(from: from, to: to, stride: stride)
        let restingHeartRate = try? await healthKitManager.fetchStatistics(
          type: .average,
          quantityType: .restingHeartRate,
          from: from,
          to: to
        )

        withAnimation {
          self.chartData = chartData
          self.restingHeartRate = restingHeartRate
          showChart = true
        }
      } catch {}
    }
  }
}
