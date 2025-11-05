//
//  ChartContent+Conditionals.swift
//  Fitness
//
//  Created by Andreas Binnewies on 11/5/25.
//

import Charts

extension ChartContent {
  @ChartContentBuilder func `if`<Content: ChartContent>(
    _ condition: Bool,
    transform: (Self) -> Content
  ) -> some ChartContent {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
