//
//  SummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/24/25.
//

import SwiftUI

struct SummaryView: View {
  let summary: Summary

  var body: some View {
    Text(summary.range.description)
      .frame(maxWidth: .infinity, alignment: .leading)
      .font(.title2)

    VStack(spacing: 8) {
      ForEach(summary.runs) { runSummary in
        RunSummaryView(runSummary: runSummary)
      }

      VStack(spacing: 0) {
        if let restingHeartRate = summary.restingHeartRate {
          SummaryRow(symbol: .heartFill, title: "Resting Heart Rate", value: String(restingHeartRate))
          Divider()
        }
        SummaryRow(symbol: .shoeprintsFill, title: "Steps", value: summary.steps.commaDelimitedString)
        Divider()
        SummaryRow(
          symbol: .flameFill,
          title: "Calories",
          value: summary.caloriesBurned.commaDelimitedString
        )
        if let distanceRunMeters = summary.distanceRunMeters, distanceRunMeters > 0 {
          Divider()
          let distanceRunMiles = distanceRunMeters.milesFromMeters
          SummaryRow(
            symbol: .figureRun,
            title: "Miles Run",
            value: String(format: "%.1f", distanceRunMiles)
          )
        }
        if let elevationAscendedMeters = summary.elevationAscendedMeters, elevationAscendedMeters > 0 {
          Divider()
          let elevationAscendedFeet = Int(elevationAscendedMeters.feetFromMeters)
          SummaryRow(
            symbol: .arrowUpRight,
            title: "Feet Ascended",
            value: elevationAscendedFeet.commaDelimitedString
          )
        }
      }
      .background(RoundedRectangle(cornerRadius: 12)
        .fill(Color(uiColor: .secondarySystemBackground)))
    }
  }
}
