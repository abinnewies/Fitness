//
//  LargeSummaryRow.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/25/25.
//

import SwiftUI

struct LargeSummaryRow: View {
  let symbol: SFSymbolName
  let title: String
  let value: String
  let unit: String

  var body: some View {
    VStack(spacing: 8) {
      MetricLabel(symbol: symbol, title: title)
        .frame(maxWidth: .infinity, alignment: .leading)

      Spacer(minLength: 8)

      HStack(alignment: .lastTextBaseline, spacing: 4) {
        Text(value)
          .font(.headline)
        Text(unit)
          .font(.subheadline)
          .foregroundStyle(Color(.secondaryLabel))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.all, 16)
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))
  }
}

#Preview {
  LargeSummaryRow(symbol: .shoeprintsFill, title: "Steps", value: "5,200", unit: "Steps")
}
