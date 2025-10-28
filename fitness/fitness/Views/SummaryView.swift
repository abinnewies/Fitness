//
//  SummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/24/25.
//

import SwiftUI

struct SummaryView: View {
  let summary: Summary
  let healthKitManager: HealthKitManager

  var body: some View {
    Text(summary.range.description)
      .frame(maxWidth: .infinity, alignment: .leading)
      .font(.title3.smallCaps())

    VStack(spacing: 8) {
      ForEach(summary.workouts) { workoutSummary in
        SmallWorkoutSummaryView(workoutSummary: workoutSummary, healthKitManager: healthKitManager)
      }

      VStack(spacing: 0) {
        if let hrv = summary.hrv {
          SummaryRow(symbol: .heartFill, title: "HRV", value: String(hrv), unit: "ms")
        }
        if let steps = summary.steps {
          Divider()
          SummaryRow(symbol: .shoeprintsFill, title: "Steps", value: steps.commaDelimitedString, unit: "steps")
        }
        if let caloriesBurned = summary.caloriesBurned {
          Divider()
          SummaryRow(
            symbol: .flameFill,
            title: "Energy",
            value: caloriesBurned.commaDelimitedString,
            unit: "calories"
          )
        }
        if let distanceRunMeters = summary.distanceRunMeters, distanceRunMeters > 0 {
          Divider()
          let distanceRunMiles = distanceRunMeters.milesFromMeters
          SummaryRow(
            symbol: .figureRun,
            title: "Distance",
            value: String(format: "%.1f", distanceRunMiles),
            unit: "miles"
          )
        }
        if let elevationAscendedMeters = summary.elevationAscendedMeters, elevationAscendedMeters > 0 {
          Divider()
          let elevationAscendedFeet = Int(elevationAscendedMeters.feetFromMeters)
          SummaryRow(
            symbol: .arrowUpRight,
            title: "Elevation",
            value: elevationAscendedFeet.commaDelimitedString,
            unit: "ft"
          )
        }
      }
      .background(RoundedRectangle(cornerRadius: 12)
        .fill(Color(uiColor: .secondarySystemBackground)))
    }
  }
}
