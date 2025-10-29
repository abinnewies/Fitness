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
      if let minHeartRate = summary.minHeartRate, let maxHeartRate = summary.maxHeartRate {
        LargeSummaryRow(
          symbol: .heartFill,
          title: "Heart Rate",
          value: "\(minHeartRate) - \(maxHeartRate)",
          unit: "bpm",
          healthKitManager: healthKitManager,
          healthSummaryMetric: .heartRate
        )
      }

      if let steps = summary.steps {
        LargeSummaryRow(
          symbol: .shoeprintsFill,
          title: "Steps",
          value: steps.commaDelimitedString,
          unit: "steps",
          healthKitManager: healthKitManager,
          healthSummaryMetric: .stepCount
        )
      }
      if let caloriesBurned = summary.caloriesBurned {
        LargeSummaryRow(
          symbol: .flameFill,
          title: "Calories",
          value: caloriesBurned.commaDelimitedString,
          unit: "calories",
          healthKitManager: healthKitManager,
          healthSummaryMetric: .caloriesBurned
        )
      }
    }
  }
}
