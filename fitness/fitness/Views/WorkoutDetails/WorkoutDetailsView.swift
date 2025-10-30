//
//  WorkoutDetailsView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/30/25.
//

import Charts
import SwiftUI

import HealthKit

struct WorkoutDetailsView: View {
  let workout: HKWorkout
  let healthKitManager: HealthKitManager

  var body: some View {
    ScrollView {
      VStack {
        WorkoutMap(workout: workout, healthKitManager: healthKitManager, displayHeatmap: true)
          .frame(maxWidth: .infinity)
          .aspectRatio(1.5, contentMode: .fill)
          .clipShape(RoundedRectangle(cornerRadius: 12))

        Spacer(minLength: 16)

        VStack(spacing: 0) {
          MetricRow(metric: WorkoutMetric.startTime, values: [
            .init(value: workout.startDate.formattedTime, unit: workout.startDate.formattedAmPm.lowercased()),
          ])
          Divider()
          MetricRow(metric: WorkoutMetric.endTime, values: [
            .init(value: workout.endDate.formattedTime, unit: workout.endDate.formattedAmPm.lowercased()),
          ])
          Divider()
          MetricRow(
            metric: WorkoutMetric.duration,
            values: [.init(value: workout.duration.durationFormattedShort, unit: "")]
          )
          if let distanceMeters = workout.distanceMeters {
            let distanceMiles = distanceMeters.milesFromMeters
            Divider()
            MetricRow(
              metric: WorkoutMetric.distance,
              values: [.init(value: String(format: "%.2f", distanceMiles), unit: "miles")]
            )

            let pace = workout.duration / distanceMiles
            Divider()
            MetricRow(
              metric: WorkoutMetric.pace,
              values: [.init(value: pace.durationFormattedShort, unit: "")]
            )
          }
          if let elevationAscendedMeters = workout.elevationAscendedMeters {
            let elevationAscendedFeet = Int(ceil(elevationAscendedMeters.feetFromMeters))
            Divider()
            MetricRow(
              metric: WorkoutMetric.elevationAscended,
              values: [.init(value: elevationAscendedFeet.commaDelimitedString, unit: "feet")]
            )
          }
          if let totalEnergyBurned = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
            Divider()
            MetricRow(
              metric: HealthSummaryMetric.caloriesBurned,
              values: [.init(value: Int(totalEnergyBurned).commaDelimitedString, unit: "calories")]
            )
          }
        }
        .background(RoundedRectangle(cornerRadius: 12)
          .fill(Color(uiColor: .secondarySystemBackground)))
      }
      .padding(16)
    }
    .navigationTitle(workout.workoutActivityType.title)
  }
}
