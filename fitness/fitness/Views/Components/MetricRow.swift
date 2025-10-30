//
//  MetricRow.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/20/25.
//

import SwiftUI

struct MetricRow: View {
  let metric: MetricRepresentable
  let values: [MetricRowValue]

  var body: some View {
    HStack(spacing: 8) {
      MetricLabel(metric: metric)
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
