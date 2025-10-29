//
//  AreaChart.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

import Charts
import SwiftUI

struct AreaChart: View {
  let from: Date
  let to: Date
  var chartData: [(x: Date, minY: Double?, maxY: Double?)]

  var body: some View {
    Chart(chartData, id: \.x) { item in
      BarMark(
        x: .value("Index", item.x),
        yStart: .value("Min", item.minY ?? 0),
        yEnd: .value("Max", item.maxY ?? 0),
        width: 3
      )
    }
    .chartXAxis {
      // TODO: We'll need to fix this to handle days
      AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .narrow)))
        AxisGridLine()
        AxisTick()
      }
    }
    .chartXScale(domain: from ... to)
    .chartYAxis(.hidden)
    .chartLegend(.hidden)
    .frame(height: 60)
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}
