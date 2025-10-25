//
//  LargeSummaryRow.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/25/25.
//

import SwiftUI

struct LargeSummaryRow: View {
  let emoji: String
  let title: String
  let value: String
  let unit: String

  var body: some View {
    VStack(spacing: 8) {
      HStack {
        Text(emoji)
        Text(title)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Spacer(minLength: 16)

      HStack(alignment: .lastTextBaseline, spacing: 4) {
        Text(value)
          .font(.title)
        Text(unit)
          .font(.subheadline)
          .foregroundStyle(Color(.secondaryLabel))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.all, 16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(uiColor: .secondarySystemBackground))
    )
  }
}

#Preview {
  LargeSummaryRow(emoji: "👣", title: "Steps", value: "5,200", unit: "Steps")
}
