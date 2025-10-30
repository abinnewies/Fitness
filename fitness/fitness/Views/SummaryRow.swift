//
//  SummaryRow.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/20/25.
//

import SwiftUI

struct SummaryRow: View {
  let summaryMetric: HealthSummaryMetric
  let values: [SummaryRowValue]

  var body: some View {
    HStack(spacing: 8) {
      MetricLabel(summaryMetric: summaryMetric)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack(spacing: 8) {
        ForEach(values) { value in
          MetricValue(value: value.value, unit: value.unit)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.all, 16)
  }
}
