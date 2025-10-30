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
          values: [
            .init(value: String(format: "%.2f", totalDistanceMiles), unit: "miles"),
          ]
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
          values: [
            .init(value: String(format: "%.2f", totalDistanceMiles), unit: "miles"),
          ]
        )
      }
    }
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))

    VStack(spacing: 0) {
      if let restingHeartRate = summary.restingHeartRate, let maxHeartRate = summary.maxHeartRate {
        SummaryRow(
          symbol: .heartFill,
          title: "Heart Rate",
          values: [
            .init(value: String(restingHeartRate), unit: "rest"),
            .init(value: String(maxHeartRate), unit: "max"),
          ]
        )
      }

      if let steps = summary.steps {
        Divider()
        SummaryRow(
          symbol: .shoeprintsFill,
          title: "Steps",
          values: [
            .init(value: steps.commaDelimitedString, unit: "steps"),
          ]
        )
      }
      if let caloriesBurned = summary.caloriesBurned {
        Divider()
        SummaryRow(
          symbol: .flameFill,
          title: "Energy",
          values: [
            .init(value: caloriesBurned.commaDelimitedString, unit: "calories"),
          ]
        )
      }
    }
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))
  }
}
