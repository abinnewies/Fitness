//
//  MetricLabel.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import SwiftUI

struct MetricLabel: View {
  let symbol: SFSymbolName
  let title: String

  var body: some View {
    Label(title, symbol: symbol)
      .labelReservedIconWidth(20)
  }
}
