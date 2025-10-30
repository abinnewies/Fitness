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
  let chartData: [(x: Date, y: Double?)]

  var body: some View {
    Chart(chartData, id: \.x) { item in
      BarMark(
        x: .value("Index", item.x),
        y: .value("Value", item.y ?? 0),
        width: 3
      )
    }
    .chartXAxis {
      // TODO: We'll need to fix this to handle days
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
    .chartXScale(domain: from ... to)
    .chartYAxis(.hidden)
    .chartLegend(.hidden)
    .frame(height: 60)
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}
