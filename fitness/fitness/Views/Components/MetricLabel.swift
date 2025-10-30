//
//  MetricLabel.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import SwiftUI

struct MetricLabel: View {
  let metric: MetricRepresentable

  var body: some View {
    Label {
      Text(metric.title)
    } icon: {
      Image(symbol: metric.symbol)
        .foregroundStyle(metric.color)
    }
    .font(.callout)
    .labelReservedIconWidth(20)
  }
}
