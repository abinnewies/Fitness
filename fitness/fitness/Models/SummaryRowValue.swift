//
//  SummaryRowValue.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

struct SummaryRowValue: Identifiable {
  let value: String
  let unit: String

  var id: String {
    unit
  }
}
