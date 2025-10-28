//
//  LargeSummaryRow.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/25/25.
//

import Charts
import SwiftUI

struct LargeSummaryRow: View {
  let symbol: SFSymbolName
  let title: String
  let value: String
  let unit: String
  let healthKitManager: HealthKitManager
  let healthMetric: HealthMetric?

  private let hourlyStride = 1

  @State private var chartData: [(x: Date, y: Double?)] = []
  @State private var showChart = false

  var body: some View {
    let startOfToday = Calendar.current.startOfDay(for: Date())
    let endOfToday = startOfToday.addingTimeInterval(86400)
    HStack(alignment: .bottom) {
      VStack(spacing: 8) {
        MetricLabel(symbol: symbol, title: title)
          .frame(maxWidth: .infinity, alignment: .leading)

        Spacer(minLength: 8)

        MetricValue(value: value, unit: unit)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      if let healthMetric, !chartData.isEmpty {
        let currentHour = Calendar.current.component(.hour, from: Date())
        Chart(chartData, id: \.x) { item in
          let isCurrentHour = Calendar.current.component(.hour, from: item.x) == currentHour
          if healthMetric.cumulative {
            BarMark(
              x: .value("Index", item.x),
              y: .value("Value", item.y ?? 0),
              width: 3
            )
            .opacity(isCurrentHour ? 1 : 0.5)
          } else {
            if let y = item.y {
              LineMark(
                x: .value("Index", item.x),
                y: .value("Value", y)
              )
              .interpolationMethod(.monotone)
              .opacity(isCurrentHour ? 1 : 0.5)

              PointMark(
                x: .value("Index", item.x),
                y: .value("Value", y)
              )
              .symbolSize(20)
              .opacity(isCurrentHour ? 1 : 0.5)
            }
          }
        }
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6)) { value in
            if let date = value.as(Date.self) {
              let hour = Calendar.current.component(.hour, from: date)
              switch hour {
              case 0, 12:
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .narrow)))
              default:
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
              }
            }

            AxisGridLine()
            AxisTick()
          }
        }
        .chartXScale(domain: startOfToday ... endOfToday)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .frame(height: 60)
        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .opacity(showChart ? 1 : 0)
        .animation(.easeIn(duration: 0.25), value: showChart)
      }
    }
    .padding(.all, 16)
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))
    .task(id: value) {
      if let healthMetric {
        do {
          let calendar = Calendar.current
          let to = Date()
          let from = calendar.startOfDay(for: to)

          let sampleManager = HealthKitSampleManager(healthKitManager: healthKitManager)
          let samples = try await sampleManager.fetchSamples(
            metric: healthMetric,
            from: from,
            to: to,
            stride: .hour(hourlyStride)
          )

          let buckets = stride(from: 0, to: 24 / hourlyStride, by: 1)
          chartData = buckets.compactMap { key in
            (x: from.addingTimeInterval(TimeInterval(key) * 3600), y: samples[key])
          }

          withAnimation {
            showChart = true
          }
        } catch {}
      }
    }
  }
}
