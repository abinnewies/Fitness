//
//  SummaryRange.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/24/25.
//

import Foundation

enum SummaryRange: Hashable {
  case today
  case yesterday
  case last7Days

  var description: String {
    switch self {
    case .today:
      "Today"
    case .yesterday:
      "Yesterday"
    case .last7Days:
      "Last 7 Days"
    }
  }

  var from: Date {
    switch self {
    case .today:
      Calendar.current.startOfDay(for: Date())
    case .yesterday:
      Calendar.current.startOfDay(for: Date().addingTimeInterval(-86400))
    case .last7Days:
      Calendar.current.startOfDay(for: Date().addingTimeInterval(-6 * 86400))
    }
  }

  var to: Date {
    switch self {
    case .yesterday:
      Calendar.current.startOfDay(for: Date()).addingTimeInterval(-1)
    case .last7Days, .today:
      Date()
    }
  }

  func averageIfNeeded<T: FloatingPoint>(_ value: T) -> T {
    switch self {
    case .yesterday, .today:
      value
    case .last7Days:
      value / 7
    }
  }
}
