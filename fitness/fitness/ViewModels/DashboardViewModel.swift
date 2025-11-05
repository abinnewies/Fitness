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

  init(healthKitManager: HealthKitManager) {
    self.healthKitManager = healthKitManager
  }

  func fetchSummary(forRange summaryRange: SummaryRange) async -> Summary {
    Summary(
      range: summaryRange,
      caloriesBurned: try? await fetchCalories(forRange: summaryRange),
      minHeartRate: try? await fetchMinHeartRate(forRange: summaryRange),
      maxHeartRate: try? await fetchMaxHeartRate(forRange: summaryRange),
      restingHeartRate: try? await fetchRestingHeartRate(forRange: summaryRange),
      sleepDuration: try? await fetchSleepDuration(forRange: summaryRange),
      steps: try? await fetchSteps(forRange: summaryRange),
      workouts: (try? await healthKitManager.fetchWorkouts(
        from: summaryRange.from,
        to: summaryRange.to
      )) ?? []
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

  private func fetchRestingHeartRate(forRange summaryRange: SummaryRange) async throws -> Int {
    let maxHeartRate = try await healthKitManager.fetchStatistics(
      type: .average,
      quantityType: .restingHeartRate,
      from: summaryRange.from,
      to: summaryRange.to
    )
    return Int(maxHeartRate)
  }

  private func fetchSleepDuration(forRange summaryRange: SummaryRange) async throws -> TimeInterval {
    let halfDaySeconds: TimeInterval = 43200
    let samples = try await healthKitManager.fetchSamples(
      from: summaryRange.from.addingTimeInterval(-halfDaySeconds),
      to: summaryRange == .yesterday ? summaryRange.to.addingTimeInterval(-halfDaySeconds) : summaryRange.to,
      sampleType: HKCategoryType(.sleepAnalysis)
    )
    let categorySamples = (samples as? [HKCategorySample]) ?? []

    let asleepValues: Set<Int> = {
      if #available(iOS 16.0, *) {
        return Set([
          HKCategoryValueSleepAnalysis.asleepCore.rawValue,
          HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
          HKCategoryValueSleepAnalysis.asleepREM.rawValue,
        ])
      } else {
        return Set([HKCategoryValueSleepAnalysis.asleep.rawValue])
      }
    }()

    let duration: TimeInterval = categorySamples.reduce(0) { partial, sample in
      guard asleepValues.contains(sample.value) else { return partial }
      return partial + sample.endDate.timeIntervalSince(sample.startDate)
    }

    switch summaryRange {
    case .today, .yesterday:
      return duration
    case .last7Days:
      return duration / 7.0
    }
  }
}
