//
//  LargeSummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/25/25.
//

import SwiftUI

struct LargeSummaryView: View {
  let summary: Summary

  var body: some View {
    VStack(spacing: 8) {
      if let restingHeartRate = summary.restingHeartRate {
        LargeSummaryRow(
          symbol: .heartFill,
          title: "Resting Heart Rate",
          value: String(restingHeartRate),
          unit: "bpm"
        )
      }
      LargeSummaryRow(
        symbol: .shoeprintsFill,
        title: "Steps",
        value: summary.steps.commaDelimitedString,
        unit: "steps"
      )
      LargeSummaryRow(
        symbol: .flameFill,
        title: "Calories",
        value: summary.caloriesBurned.commaDelimitedString,
        unit: "calories"
      )
      if let distanceRunMeters = summary.distanceRunMeters, distanceRunMeters > 0 {
        let distanceRunMiles = distanceRunMeters.milesFromMeters
        LargeSummaryRow(
          symbol: .figureRun,
          title: "Miles Run",
          value: String(format: "%.1f", distanceRunMiles),
          unit: "miles"
        )
      }
      if let elevationAscendedMeters = summary.elevationAscendedMeters, elevationAscendedMeters > 0 {
        let elevationAscendedFeet = Int(elevationAscendedMeters.feetFromMeters)
        LargeSummaryRow(
          symbol: .mountain2Fill,
          title: "Feet Ascended",
          value: elevationAscendedFeet.commaDelimitedString,
          unit: "feet"
        )
      }
    }
  }
}

#Preview {
  SummaryView(summary: .init(
    range: .today,
    caloriesBurned: 3175,
    elevationAscendedMeters: 1200,
    distanceRunMeters: 16093.4,
    restingHeartRate: 60,
    steps: 34501,
    runs: []
  ))
}
