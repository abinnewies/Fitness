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

  var body: some View {
    HStack(spacing: 8) {
      MetricLabel(symbol: symbol, title: title)

      Spacer()

      MetricValue(value: value, unit: nil)
    }
    .padding(.all, 16)
  }
}

#Preview {
  SummaryRow(symbol: .shoeprintsFill, title: "Steps", value: "5,200")
}
