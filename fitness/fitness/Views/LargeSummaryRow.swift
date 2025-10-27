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
  let samples: [Int: Sample]?

  private var chartData: [(x: Int, y: Double)] {
    guard let samples, !samples.isEmpty else {
      return []
    }
    return samples.keys.compactMap { key in
      if let sample = samples[key] {
        return (x: key, y: Double(sample.value))
      }
      return nil
    }
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      VStack(spacing: 8) {
        MetricLabel(symbol: symbol, title: title)
          .frame(maxWidth: .infinity, alignment: .leading)

        Spacer(minLength: 8)

        MetricValue(value: value, unit: unit)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.all, 16)
      .background(RoundedRectangle(cornerRadius: 12)
        .fill(Color(uiColor: .secondarySystemBackground)))

      if !chartData.isEmpty {
        Chart(chartData, id: \.x) { item in
          BarMark(
            x: .value("Index", item.x),
            y: .value("Value", item.y)
          )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .frame(width: 80, height: 36)
        .padding(.trailing, 12)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
      }
    }
  }
}
