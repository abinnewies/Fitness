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
  let chartData: [(x: Date, y1: Double?, y2: Double?)]
  let secondaryColor: Color

  var body: some View {
    Chart {
      ForEach(chartData, id: \.x) { item in
        if let v1 = item.y1, v1 != 0 {
          BarMark(
            x: .value("Index", item.x),
            y: .value("Value", v1),
            width: 3
          )
        }
        if let v2 = item.y2, v2 != 0 {
          BarMark(
            x: .value("Index", item.x),
            y: .value("Value", v2),
            width: 3
          )
          .foregroundStyle(secondaryColor)
        }
      }
    }
    .chartPlotStyle { plotArea in
      plotArea
        .chartOverlay { _ in
          Color.clear
        }
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
