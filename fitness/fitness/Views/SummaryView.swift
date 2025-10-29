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

    VStack(spacing: 0) {
      let runs = summary.workouts.compactMap(\.runSummary)
      let hikes = summary.workouts.compactMap(\.hikeSummary)
      if !runs.isEmpty {
        let totalDistanceMiles = runs.compactMap(\.distanceMeters).reduce(0, +).milesFromMeters
        SummaryRow(
          symbol: .figureRun,
          title: runs.count == 1 ? "Run" : "\(runs.count) Runs",
          value: String(format: "%.2f", totalDistanceMiles),
          unit: "miles"
        )
      }

      if !hikes.isEmpty {
        if !runs.isEmpty {
          Divider()
        }
        let totalDistanceMiles = hikes.compactMap(\.distanceMeters).reduce(0, +).milesFromMeters
        SummaryRow(
          symbol: .figureWalk,
          title: hikes.count == 1 ? "Hike" : "\(hikes.count) Hikes",
          value: String(format: "%.2f", totalDistanceMiles),
          unit: "miles"
        )
      }
    }
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))

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
    }
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))
  }
}
