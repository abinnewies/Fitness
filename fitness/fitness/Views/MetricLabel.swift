//
//  MetricLabel.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import SwiftUI

struct MetricLabel: View {
  let summaryMetric: HealthSummaryMetric

  var body: some View {
    Label {
      Text(summaryMetric.title)
    } icon: {
      Image(symbol: summaryMetric.symbol)
        .foregroundStyle(summaryMetric.color)
    }
    .font(.callout)
    .labelReservedIconWidth(20)
  }
}
