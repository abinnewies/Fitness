//
//  SummaryRow.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/20/25.
//

import SwiftUI

struct SummaryRow: View {
  let symbol: SFSymbolName
  let title: String
  let value: String
  let unit: String?

  var body: some View {
    HStack(spacing: 8) {
      MetricLabel(symbol: symbol, title: title)
        .frame(maxWidth: .infinity, alignment: .leading)

      MetricValue(value: value, unit: unit)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.all, 16)
  }
}
