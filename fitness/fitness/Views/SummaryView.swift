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

    VStack(spacing: 0) {
      if let restingHeartRate = summary.restingHeartRate {
        SummaryRow(emoji: "❤️", title: "Resting Heart Rate", value: String(restingHeartRate))
      }
      SummaryRow(emoji: "👣", title: "Steps", value: summary.steps.commaDelimitedString)
      Divider()
      SummaryRow(emoji: "🔥", title: "Calories", value: summary.caloriesBurned.commaDelimitedString)
      if summary.milesRun > 0 {
        Divider()
        SummaryRow(emoji: "👟", title: "Miles Run", value: String(format: "%.1f", summary.milesRun))
      }
      if summary.elevationAscended > 0 {
        Divider()
        SummaryRow(emoji: "🏔️", title: "Feet Ascended", value: summary.elevationAscended.commaDelimitedString)
      }
    }
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))
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
