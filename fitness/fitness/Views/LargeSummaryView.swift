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
        LargeSummaryRow(emoji: "❤️", title: "Resting Heart Rate", value: String(restingHeartRate), unit: "bpm")
      }
      LargeSummaryRow(emoji: "👣", title: "Steps", value: summary.steps.commaDelimitedString, unit: "steps")
      LargeSummaryRow(
        emoji: "🔥",
        title: "Calories",
        value: summary.caloriesBurned.commaDelimitedString,
        unit: "calories"
      )
      if summary.milesRun > 0 {
        LargeSummaryRow(emoji: "👟", title: "Miles Run", value: String(format: "%.1f", summary.milesRun), unit: "miles")
      }
      if summary.elevationAscended > 0 {
        LargeSummaryRow(
          emoji: "🏔️",
          title: "Feet Ascended",
          value: summary.elevationAscended.commaDelimitedString,
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
    elevationAscended: 1200,
    milesRun: 10,
    restingHeartRate: 60,
    steps: 34501
  ))
}
