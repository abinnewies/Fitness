//
//  LargeSummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/25/25.
//

import SwiftUI

struct LargeSummaryView: View {
  let summary: Summary
  let healthKitManager: HealthKitManager

  var body: some View {
    VStack(spacing: 8) {
      if let hrv = summary.hrv {
        LargeSummaryRow(
          symbol: .heartFill,
          title: "HRV",
          value: String(hrv),
          unit: "ms",
          healthKitManager: healthKitManager,
          healthMetric: .hrv
        )
      }
      if let steps = summary.steps {
        LargeSummaryRow(
          symbol: .shoeprintsFill,
          title: "Steps",
          value: steps.commaDelimitedString,
          unit: "steps",
          healthKitManager: healthKitManager,
          healthMetric: .stepCount
        )
      }
      if let caloriesBurned = summary.caloriesBurned {
        LargeSummaryRow(
          symbol: .flameFill,
          title: "Calories",
          value: caloriesBurned.commaDelimitedString,
          unit: "calories",
          healthKitManager: healthKitManager,
          healthMetric: .caloriesBurned
        )
      }
      if let distanceRunMeters = summary.distanceRunMeters, distanceRunMeters > 0 {
        let distanceRunMiles = distanceRunMeters.milesFromMeters
        LargeSummaryRow(
          symbol: .figureRun,
          title: "Distance",
          value: String(format: "%.1f", distanceRunMiles),
          unit: "miles",
          healthKitManager: healthKitManager,
          healthMetric: nil
        )
      }
      if let elevationAscendedMeters = summary.elevationAscendedMeters, elevationAscendedMeters > 0 {
        let elevationAscendedFeet = Int(elevationAscendedMeters.feetFromMeters)
        LargeSummaryRow(
          symbol: .mountain2Fill,
          title: "Elevation",
          value: elevationAscendedFeet.commaDelimitedString,
          unit: "feet",
          healthKitManager: healthKitManager,
          healthMetric: nil
        )
      }
    }
  }
}
