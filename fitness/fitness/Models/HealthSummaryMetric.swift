//
//  HealthSummaryMetric.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

import SwiftUI

enum HealthSummaryMetric: Hashable, MetricRepresentable {
  case caloriesBurned
  case heartRate
  case hikes(Int)
  case runs(Int)
  case stepCount

  var title: String {
    switch self {
    case .caloriesBurned:
      "Calories"
    case .heartRate:
      "Heart Rate"
    case let .hikes(count):
      count == 1 ? "Hike" : "\(count) Hikes"
    case let .runs(count):
      count == 1 ? "Run" : "\(count) Runs"
    case .stepCount:
      "Steps"
    }
  }

  var symbol: SFSymbolName {
    switch self {
    case .caloriesBurned:
      .flameFill
    case .heartRate:
      .heartFill
    case .hikes:
      .figureWalk
    case .runs:
      .figureRun
    case .stepCount:
      .shoeprintsFill
    }
  }

  var color: Color {
    switch self {
    case .caloriesBurned:
      .caloriesBurned
    case .heartRate:
      .heartRate
    case .hikes:
      .hike
    case .runs:
      .run
    case .stepCount:
      .stepCount
    }
  }
}
