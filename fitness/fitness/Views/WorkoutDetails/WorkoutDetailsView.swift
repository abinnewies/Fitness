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
  @State private var viewModel: WorkoutDetailsViewModel
  private let workout: HKWorkout
  private let healthKitManager: HealthKitManager

  var body: some View {
    ScrollView {
      if viewModel.hasLoaded {
        VStack(spacing: 16) {
          if viewModel.hasRoute {
            VStack(spacing: 8) {
              WorkoutMap(workout: workout, healthKitManager: healthKitManager, displayHeatmap: true, fadeTerrain: false)
                .frame(maxWidth: .infinity)
                .aspectRatio(1.5, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 12))

              if let cityName = viewModel.cityName {
                Label(cityName, symbol: .locationFill)
                  .frame(maxWidth: .infinity, alignment: .trailing)
                  .font(.subheadline)
              }
            }
          }

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
            if let averageHeartRate = workout.averageHeartRate {
              Divider()
              MetricRow(
                metric: HealthMetric.averageHeartRate,
                values: [.init(value: String(averageHeartRate), unit: "bpm")]
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

          VStack(spacing: 8) {
            MetricLabel(metric: HealthMetric.heartRate)
              .frame(maxWidth: .infinity, alignment: .leading)

            WorkoutHeartRateChart(
              from: workout.startDate,
              to: workout.endDate,
              currentDate: Date(),
              healthKitManager: healthKitManager,
              stride: .timeInterval(workout.endDate.timeIntervalSince(workout.startDate) / 60)
            )
            .aspectRatio(2, contentMode: .fill)
            .frame(maxWidth: .infinity)
          }
          .padding(16)
          .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(uiColor: .secondarySystemBackground)))
        }
        .padding(16)
      }
    }
    .navigationTitle(workout.workoutActivityType.title)
    .task {
      do {
        try await viewModel.loadData()
      } catch {}
    }
  }

  init(workout: HKWorkout, healthKitManager: HealthKitManager) {
    self.workout = workout
    self.healthKitManager = healthKitManager
    viewModel = WorkoutDetailsViewModel(workout: workout, healthKitManager: healthKitManager)
  }
}
