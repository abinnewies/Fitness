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
  let hideIcon: Bool

  var body: some View {
    HStack(spacing: 8) {
      MetricLabel(metric: metric, hideIcon: hideIcon)
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

  init(metric: MetricRepresentable, values: [MetricRowValue], hideIcon: Bool = false) {
    self.metric = metric
    self.values = values
    self.hideIcon = hideIcon
  }
}
