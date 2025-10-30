//
//  WorkoutMetric.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/30/25.
//

import SwiftUI

protocol MetricRepresentable {
  var title: String { get }
  var symbol: SFSymbolName { get }
  var color: Color { get }
}

enum WorkoutMetric: Hashable, MetricRepresentable {
  case distance
  case duration
  case elevationAscended
  case endTime
  case pace
  case startTime

  var title: String {
    switch self {
    case .distance:
      "Distance"
    case .duration:
      "Duration"
    case .elevationAscended:
      "Elevation"
    case .endTime:
      "End Time"
    case .pace:
      "Pace"
    case .startTime:
      "Start Time"
    }
  }

  var symbol: SFSymbolName {
    switch self {
    case .distance:
      .ruler
    case .duration:
      .clockArrowTrianglehead
    case .elevationAscended:
      .arrowUpRight
    case .endTime:
      .clockFill
    case .startTime:
      .clock
    case .pace:
      .timer
    }
  }

  var color: Color {
    switch self {
    case .distance:
      .distance
    case .duration:
      .duration
    case .elevationAscended:
      .elevationAscended
    case .endTime:
      .endTime
    case .pace:
      .pace
    case .startTime:
      .startTime
    }
  }
}
