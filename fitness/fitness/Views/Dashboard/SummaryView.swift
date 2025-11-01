//
//  SummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/24/25.
//

import HealthKit
import SwiftUI

struct SummaryView: View {
  let summary: Summary
  let healthKitManager: HealthKitManager
  @Binding var navigationPath: NavigationPath

  var body: some View {
    Text(summary.range.description)
      .frame(maxWidth: .infinity, alignment: .leading)
      .font(.title3)

    Spacer(minLength: 8)

    VStack(spacing: 0) {
      let runs = summary.workouts.filter { $0.workoutActivityType == .running }
      let hikes = summary.workouts.filter { $0.workoutActivityType == .hiking }
      if !runs.isEmpty {
        ForEach(runs) { run in
          WorkoutSummaryView(workout: run, healthKitManager: healthKitManager)
            .contentShape(Rectangle())
            .onTapGesture {
              UISelectionFeedbackGenerator().selectionChanged()
              navigationPath.append(NavigationDestination.workoutDetails(run))
            }
        }
        let totalDistanceMiles = runs.compactMap(\.distanceMeters).reduce(0, +).milesFromMeters
        MetricRow(
          metric: HealthSummaryMetric.runs(runs.count),
          values: [
            .init(value: String(format: "%.2f", totalDistanceMiles), unit: "miles"),
          ]
        )
        .contentShape(Rectangle())
        .onTapGesture {
          UISelectionFeedbackGenerator().selectionChanged()
          navigationPath.append(NavigationDestination.workoutList(.running))
        }
      }

      if !hikes.isEmpty {
        if !runs.isEmpty {
          Divider()
        }
        let totalDistanceMiles = hikes.compactMap(\.distanceMeters).reduce(0, +).milesFromMeters
        MetricRow(
          metric: HealthSummaryMetric.hikes(hikes.count),
          values: [
            .init(value: String(format: "%.2f", totalDistanceMiles), unit: "miles"),
          ]
        )
        .contentShape(Rectangle())
        .onTapGesture {
          UISelectionFeedbackGenerator().selectionChanged()
          navigationPath.append(NavigationDestination.workoutList(.hiking))
        }
      }
    }
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))

    VStack(spacing: 0) {
      if let restingHeartRate = summary.restingHeartRate, let maxHeartRate = summary.maxHeartRate {
        MetricRow(
          metric: HealthSummaryMetric.heartRate,
          values: [
            .init(value: String(restingHeartRate), unit: "rest"),
            .init(value: String(maxHeartRate), unit: "max"),
          ]
        )
      }

      if let steps = summary.steps {
        Divider()
        MetricRow(
          metric: HealthSummaryMetric.stepCount,
          values: [
            .init(value: steps.commaDelimitedString, unit: "steps"),
          ]
        )
      }
      if let caloriesBurned = summary.caloriesBurned {
        Divider()
        MetricRow(
          metric: HealthSummaryMetric.caloriesBurned,
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
