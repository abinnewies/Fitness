//
//  MetricValue.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import SwiftUI

struct MetricValue: View {
  let value: String
  let unit: String?

  var body: some View {
    HStack(alignment: .lastTextBaseline, spacing: 4) {
      Text(value)
        .font(.title3.bold())
      if let unit {
        Text(unit)
          .font(.subheadline)
          .foregroundStyle(Color(.secondaryLabel))
      }
    }
  }
}
