//
//  HKWorkoutActivityType+Display.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/30/25.
//

import HealthKit
import SwiftUI

extension HKWorkoutActivityType {
  var title: String {
    switch self {
    case .hiking:
      "Hike"
    case .running:
      "Run"
    default:
      "Activity"
    }
  }

  var symbol: SFSymbolName {
    switch self {
    case .hiking:
      .figureWalk
    case .running:
      .figureRun
    default:
      .figureStand
    }
  }

  var color: Color {
    switch self {
    case .hiking:
      Color.hike
    case .running:
      Color.run
    default:
      .accentColor
    }
  }
}
