//
//  DashboardViewModel.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import HealthKit
import SwiftUI

enum HourlyQuantityType {
  case caloriesBurned
  case stepCount
}

@Observable
class DashboardViewModel {
  private let healthKitManager: HealthKitManager

  private let bpm = HKUnit.count().unitDivided(by: HKUnit.minute())

  init(healthKitManager: HealthKitManager) {
    self.healthKitManager = healthKitManager
  }

  func fetchSummary(forRange summaryRange: SummaryRange) async throws -> Summary {
    try Summary(
      range: summaryRange,
      caloriesBurned: await fetchCalories(forRange: summaryRange),
      elevationAscendedMeters: summaryRange == .last7Days ? await fetchElevationAscended(forRange: summaryRange) : nil,
      distanceRunMeters: summaryRange == .last7Days ? await fetchMetersRun(forRange: summaryRange) : nil,
      restingHeartRate: try? await fetchingRestingHeartRate(forRange: summaryRange),
      steps: await fetchSteps(forRange: summaryRange),
      runs: await fetchRunSummaries(forRange: summaryRange),
      calorieSamples: summaryRange == .today ? await fetchHourlySampleData(type: .caloriesBurned, hourStride: 3) : [:],
      stepCountSamples: summaryRange == .today ? await fetchHourlySampleData(type: .stepCount, hourStride: 3) : [:]
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

  private func fetchingRestingHeartRate(forRange summaryRange: SummaryRange) async throws -> Int {
    let restingHeartRate = try await healthKitManager.fetchStatistics(
      type: .average,
      quantityType: .restingHeartRate,
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

  private func fetchRunSummaries(forRange summaryRange: SummaryRange) async throws -> [RunSummary] {
    guard summaryRange != .last7Days else {
      return []
    }

    let workouts = try await healthKitManager.fetchWorkouts(
      from: summaryRange.from,
      to: summaryRange.to,
      ofType: .running
    )

    var summaries: [RunSummary] = []
    for workout in workouts {
      let route = try? await healthKitManager.fetchRoutes(for: workout).first
      let routePoints: [RoutePoint]
      if let route {
        routePoints = (try? await healthKitManager.fetchRoutePoints(for: route)) ?? []
      } else {
        routePoints = []
      }
      let summary = RunSummary(
        id: workout.uuid.uuidString,
        distanceMeters: workout.distanceMeters,
        duration: workout.duration,
        elevationAscendedMeters: workout.elevationAscendedMeters,
        routePoints: routePoints
      )
      summaries.append(summary)
    }
    return summaries
  }

  func fetchHourlySampleData(type: HourlyQuantityType, hourStride: Int) async throws -> [Int: Sample] {
    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)

    let allSamples: [Sample]
    switch type {
    case .stepCount:
      allSamples = try await healthKitManager.fetchSamples(type: .stepCount, from: startOfDay, to: now)
    case .caloriesBurned:
      let activeEnergySamples = try await healthKitManager.fetchSamples(
        type: .activeEnergyBurned,
        from: startOfDay,
        to: now
      )
      let basalEnergySamples = try await healthKitManager.fetchSamples(
        type: .basalEnergyBurned,
        from: startOfDay,
        to: now
      )
      allSamples = activeEnergySamples + basalEnergySamples
    }

    var hourlyTotals: [Int: Sample] = [:]
    for sample in allSamples {
      let hour = calendar.component(.hour, from: sample.date) / hourStride
      if let existing = hourlyTotals[hour] {
        hourlyTotals[hour] = Sample(value: existing.value + sample.value, date: existing.date)
      } else {
        hourlyTotals[hour] = sample
      }
    }

    return hourlyTotals
  }
}
