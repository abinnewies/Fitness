//
//  BarChart.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

import Charts
import SwiftUI

struct BarChart: View {
  let from: Date
  let to: Date
  let color: Color
  let chartData: [(x: Date, y: Double?)]

  var body: some View {
    Chart(chartData, id: \.x) { item in
      BarMark(
        x: .value("Index", item.x),
        y: .value("Value", item.y ?? 0),
        width: 3
      )
      .foregroundStyle(color)
    }
    .chartXAxis {
      let totalSegments = 3
      let start = from.timeIntervalSinceReferenceDate
      let end = to.timeIntervalSinceReferenceDate
      let step = (end - start) / Double(totalSegments)
      let ticks: [Date] = (0 ... totalSegments).map { i in
        Date(timeIntervalSinceReferenceDate: start + Double(i) * step)
      }

      AxisMarks(preset: .aligned, values: ticks) { value in
        AxisGridLine()
        AxisTick()
        AxisValueLabel {
          if let date = value.as(Date.self) {
            Text(date.formattedHourOfDay)
              .if(date == ticks.first || date == ticks.last) {
                $0.frame(width: 40, alignment: .leading)
              }
              .if(date == ticks.first) {
                $0.offset(x: 20)
              }
          }
        }
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
