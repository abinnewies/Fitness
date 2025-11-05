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
      if let sleep = summary.sleepDuration {
        LargeSummaryRow(
          summaryDate: summary.date,
          values: [
            .init(value: sleep.durationFormatted(includeSeconds: false), unit: ""),
          ],
          healthKitManager: healthKitManager,
          healthSummaryMetric: .sleep
        )
      }

      if let restingHeartRate = summary.restingHeartRate, let maxHeartRate = summary.maxHeartRate {
        LargeSummaryRow(
          summaryDate: summary.date,
          values: [
            .init(value: String(restingHeartRate), unit: "rest"),
            .init(value: String(maxHeartRate), unit: "max"),
          ],
          healthKitManager: healthKitManager,
          healthSummaryMetric: .heartRate
        )
      }

      if let steps = summary.steps {
        LargeSummaryRow(
          summaryDate: summary.date,
          values: [
            .init(value: steps.commaDelimitedString, unit: "steps"),
          ],
          healthKitManager: healthKitManager,
          healthSummaryMetric: .stepCount
        )
      }

      if let caloriesBurned = summary.caloriesBurned {
        LargeSummaryRow(
          summaryDate: summary.date,
          values: [
            .init(value: caloriesBurned.commaDelimitedString, unit: "calories"),
          ],
          healthKitManager: healthKitManager,
          healthSummaryMetric: .caloriesBurned
        )
      }
    }
  }
}
