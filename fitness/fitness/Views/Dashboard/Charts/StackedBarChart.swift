//
//  StackedBarChart.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

import Charts
import SwiftUI

struct StackedBarChart: View {
  let from: Date
  let to: Date
  let bottomColor: Color
  let topColor: Color
  let chartData: [(x: Date, y1: Double?, y2: Double?)]

  var body: some View {
    Chart {
      ForEach(chartData, id: \.x) { item in
        if let v1 = item.y1, v1 != 0 {
          BarMark(
            x: .value("Index", item.x),
            y: .value("Value", v1),
            width: 3
          )
          .foregroundStyle(bottomColor)
        }
        if let v2 = item.y2, v2 != 0 {
          BarMark(
            x: .value("Index", item.x),
            y: .value("Value", v2),
            width: 3
          )
          .foregroundStyle(topColor)
        }
      }
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
