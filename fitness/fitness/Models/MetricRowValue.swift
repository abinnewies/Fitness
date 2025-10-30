//
//  MetricRowValue.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

struct MetricRowValue: Identifiable {
  let value: String
  let unit: String

  var id: String {
    unit
  }
}
