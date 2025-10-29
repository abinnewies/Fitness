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
      minHeartRate: try? await fetchMinHeartRate(forRange: summaryRange),
      maxHeartRate: try? await fetchMaxHeartRate(forRange: summaryRange),
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

  private func fetchMinHeartRate(forRange summaryRange: SummaryRange) async throws -> Int {
    let minHeartRate = try await healthKitManager.fetchStatistics(
      type: .min,
      quantityType: .heartRate,
      from: summaryRange.from,
      to: summaryRange.to
    )
    return Int(minHeartRate)
  }

  private func fetchMaxHeartRate(forRange summaryRange: SummaryRange) async throws -> Int {
    let maxHeartRate = try await healthKitManager.fetchStatistics(
      type: .max,
      quantityType: .heartRate,
      from: summaryRange.from,
      to: summaryRange.to
    )
    return Int(maxHeartRate)
  }

  private func fetchWorkoutSummaries(forRange summaryRange: SummaryRange) async throws -> [WorkoutSummary] {
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
