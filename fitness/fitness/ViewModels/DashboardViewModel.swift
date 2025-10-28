//
//  DashboardViewModel.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import HealthKit
import SwiftUI

@Observable
class DashboardViewModel {
  private let healthKitManager: HealthKitManager

  private let bpm = HKUnit.count().unitDivided(by: HKUnit.minute())

  init(healthKitManager: HealthKitManager) {
    self.healthKitManager = healthKitManager
  }

  func fetchSummary(forRange summaryRange: SummaryRange) async -> Summary {
    Summary(
      range: summaryRange,
      caloriesBurned: try? await fetchCalories(forRange: summaryRange),
      elevationAscendedMeters: summaryRange == .last7Days ? try? await fetchElevationAscended(forRange: summaryRange) :
        nil,
      distanceRunMeters: summaryRange == .last7Days ? try? await fetchMetersRun(forRange: summaryRange) : nil,
      hrv: try? await fetchHeartRateVariability(forRange: summaryRange),
      steps: try? await fetchSteps(forRange: summaryRange),
      workouts: (try? await fetchWorkoutSummaries(forRange: summaryRange)) ?? []
    )
  }

  private func fetchSteps(forRange summaryRange: SummaryRange) async throws -> Int {
    let steps = try await healthKitManager.fetchStatistics(
      type: .cumulativeSum,
      quantityType: .stepCount,
      from: summaryRange.from,
      to: summaryRange.to
    )
    return Int(summaryRange.averageIfNeeded(steps))
  }

  private func fetchCalories(forRange summaryRange: SummaryRange) async throws -> Int {
    let activeCalories = try await healthKitManager.fetchStatistics(
      type: .cumulativeSum,
      quantityType: .activeEnergyBurned,
      from: summaryRange.from,
      to: summaryRange.to
    )
    let passiveCalories = try await healthKitManager.fetchStatistics(
      type: .cumulativeSum,
      quantityType: .basalEnergyBurned,
      from: summaryRange.from,
      to: summaryRange.to
    )

    return Int(summaryRange.averageIfNeeded(activeCalories + passiveCalories))
  }

  private func fetchHeartRateVariability(forRange summaryRange: SummaryRange) async throws -> Int {
    let restingHeartRate = try await healthKitManager.fetchStatistics(
      type: .average,
      quantityType: .hrv,
      from: summaryRange.from,
      to: summaryRange.to
    )
    return Int(round(restingHeartRate))
  }

  private func fetchMetersRun(forRange summaryRange: SummaryRange) async throws -> Double {
    let workouts = try await healthKitManager.fetchWorkouts(
      from: summaryRange.from,
      to: summaryRange.to,
      ofType: .running
    )
    let totalMeters = workouts
      .compactMap(\.distanceMeters)
      .reduce(0, +)
    return totalMeters
  }

  private func fetchElevationAscended(forRange summaryRange: SummaryRange) async throws -> Double {
    let workouts = try await healthKitManager.fetchWorkouts(
      from: summaryRange.from,
      to: summaryRange.to,
      ofType: .running
    )
    let totalMetersAscended: Double = workouts.compactMap(\.elevationAscendedMeters).reduce(0, +)
    return totalMetersAscended
  }

  private func fetchWorkoutSummaries(forRange summaryRange: SummaryRange) async throws -> [WorkoutSummary] {
    guard summaryRange != .last7Days else {
      return []
    }

    let workouts = try await healthKitManager.fetchWorkouts(
      from: summaryRange.from,
      to: summaryRange.to
    )

    return workouts.compactMap { workout in
      switch workout.workoutActivityType {
      case .running:
        .run(RunSummary(
          id: workout.uuid.uuidString,
          distanceMeters: workout.distanceMeters ?? 0,
          duration: workout.duration,
          elevationAscendedMeters: workout.elevationAscendedMeters,
          workout: workout
        ))
      case .hiking:
        .hike(HikeSummary(
          id: workout.uuid.uuidString,
          distanceMeters: workout.distanceMeters ?? 0,
          duration: workout.duration,
          elevationAscendedMeters: workout.elevationAscendedMeters,
          workout: workout
        ))
      default:
        nil
      }
    }
  }
}
