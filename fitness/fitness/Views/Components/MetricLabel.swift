//
//  MetricLabel.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import SwiftUI

struct MetricLabel: View {
  let metric: MetricRepresentable
  let hideIcon: Bool

  var body: some View {
    if hideIcon {
      Text(metric.title)
        .font(.callout)
        .labelReservedIconWidth(20)
    } else {
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

  init(metric: MetricRepresentable, hideIcon: Bool = false) {
    self.metric = metric
    self.hideIcon = hideIcon
  }
}
