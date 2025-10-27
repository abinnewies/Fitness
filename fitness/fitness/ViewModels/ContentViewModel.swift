//
//  ContentViewModel.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/16/25.
//

import Combine
import CoreLocation
import HealthKit
import SwiftUI

struct HourlyHeartRateSample {
  let minHeartRate: Double
  let maxHeartRate: Double
  let hour: Date
}

enum ContentViewModelError: Error {
  case missingValue
}

enum HourlyQuantityType {
  case caloriesBurned
  case stepCount
}

private enum StatisticsType {
  case cumulativeSum
  case average

  var healthKitType: HKStatisticsOptions {
    switch self {
    case .cumulativeSum:
      .cumulativeSum
    case .average:
      .discreteAverage
    }
  }
}

private enum QuantityType {
  case activeEnergyBurned
  case basalEnergyBurned
  case stepCount

  var type: HKQuantityType {
    switch self {
    case .activeEnergyBurned:
      HKQuantityType(.activeEnergyBurned)
    case .basalEnergyBurned:
      HKQuantityType(.basalEnergyBurned)
    case .stepCount:
      HKQuantityType(.stepCount)
    }
  }

  var unit: HKUnit {
    switch self {
    case .stepCount:
      HKUnit.count()
    case .activeEnergyBurned, .basalEnergyBurned:
      HKUnit.kilocalorie()
    }
  }
}

struct Sample {
  let value: Double
  let date: Date
}

@Observable
class ContentViewModel {
  var heartRate: Double?

  private let store = HKHealthStore()

  private var heartRateAnchor: HKQueryAnchor?

  private let healthDataTypes: Set<HKObjectType> = [
    HKQuantityType(.heartRate),
    HKQuantityType(.restingHeartRate),
    HKQuantityType(.activeEnergyBurned),
    HKQuantityType(.basalEnergyBurned),
    HKQuantityType(.stepCount),
    HKObjectType.workoutType(),
    HKSeriesType.workoutRoute(),
  ]

  private var anchor: HKQueryAnchor?

  private let bpm = HKUnit.count().unitDivided(by: HKUnit.minute())

  func requestHealthKitAuthorization() async throws {
    try await store.requestAuthorization(toShare: Set(), read: healthDataTypes)
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

  func fetchSteps(forRange summaryRange: SummaryRange) async throws -> Int {
    let steps = try await fetchStatistics(
      type: .cumulativeSum,
      quantityType: HKQuantityType(.stepCount),
      unit: .count(),
      from: summaryRange.from,
      to: summaryRange.to
    )
    return Int(summaryRange.averageIfNeeded(steps))
  }

  func fetchCalories(forRange summaryRange: SummaryRange) async throws -> Int {
    let activeCalories = try await fetchStatistics(
      type: .cumulativeSum,
      quantityType: HKQuantityType(.activeEnergyBurned),
      unit: .kilocalorie(),
      from: summaryRange.from,
      to: summaryRange.to
    )
    let passiveCalories = try await fetchStatistics(
      type: .cumulativeSum,
      quantityType: HKQuantityType(.basalEnergyBurned),
      unit: .kilocalorie(),
      from: summaryRange.from,
      to: summaryRange.to
    )

    return Int(summaryRange.averageIfNeeded(activeCalories + passiveCalories))
  }

  func fetchingRestingHeartRate(forRange summaryRange: SummaryRange) async throws -> Int {
    let restingHeartRate = try await fetchStatistics(
      type: .average,
      quantityType: HKQuantityType(.restingHeartRate),
      unit: bpm,
      from: summaryRange.from,
      to: summaryRange.to
    )
    return Int(round(restingHeartRate))
  }

  private func fetchRunSummaries(forRange summaryRange: SummaryRange) async throws -> [RunSummary] {
    guard summaryRange != .last7Days else {
      return []
    }

    let workouts = try await fetchWorkouts(from: summaryRange.from, to: summaryRange.to, ofType: .running)

    var summaries: [RunSummary] = []
    for workout in workouts {
      let route = try? await fetchRoutes(for: workout).first
      let routePoints: [RoutePoint]
      if let route {
        routePoints = (try? await fetchRoutePoints(for: route)) ?? []
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

  private func fetchWorkouts(from: Date, to: Date, ofType type: HKWorkoutActivityType) async throws -> [HKWorkout] {
    let workoutType = HKObjectType.workoutType()
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
      HKQuery.predicateForWorkouts(with: type),
      HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate),
    ])

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: workoutType,
        predicate: predicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: nil
      ) { _, samples, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
      }
      store.execute(query)
    }
  }

  private func fetchRoutes(for workout: HKWorkout) async throws -> [HKWorkoutRoute] {
    let predicate = HKQuery.predicateForObjects(from: workout)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: HKSeriesType.workoutRoute(),
        predicate: predicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: nil
      ) { _, samples, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        let routes = samples as? [HKWorkoutRoute] ?? []
        continuation.resume(returning: routes)
      }

      store.execute(query)
    }
  }

  private func fetchRoutePoints(for route: HKWorkoutRoute) async throws -> [RoutePoint] {
    return try await withCheckedThrowingContinuation { continuation in
      var routePoints: [RoutePoint] = []

      let query = HKWorkoutRouteQuery(route: route) { _, locations, done, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        if let locations {
          routePoints.append(contentsOf: locations.map {
            RoutePoint(location: $0)
          })
        }

        if done {
          continuation.resume(returning: routePoints)
        }
      }

      store.execute(query)
    }
  }

  func fetchMetersRun(forRange summaryRange: SummaryRange) async throws -> Double {
    let workouts = try await fetchWorkouts(from: summaryRange.from, to: summaryRange.to, ofType: .running)
    let totalMeters = workouts
      .compactMap(\.distanceMeters)
      .reduce(0, +)
    return totalMeters
  }

  func fetchElevationAscended(forRange summaryRange: SummaryRange) async throws -> Double {
    let workouts = try await fetchWorkouts(from: summaryRange.from, to: summaryRange.to, ofType: .running)
    let totalMetersAscended: Double = workouts.compactMap(\.elevationAscendedMeters).reduce(0, +)
    return totalMetersAscended
  }

  func fetchHourlySampleData(type: HourlyQuantityType, hourStride: Int) async throws -> [Int: Sample] {
    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)

    let allSamples: [Sample]
    switch type {
    case .stepCount:
      allSamples = try await fetchSamples(type: .stepCount, from: startOfDay, to: now)
    case .caloriesBurned:
      let activeEnergySamples = try await fetchSamples(type: .activeEnergyBurned, from: startOfDay, to: now)
      let basalEnergySamples = try await fetchSamples(type: .basalEnergyBurned, from: startOfDay, to: now)
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

  private func fetchSamples(type: QuantityType, from: Date, to: Date) async throws -> [Sample] {
    let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: type.type,
        predicate: predicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: [sortDescriptor]
      ) { _, samples, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        guard let samples = samples as? [HKQuantitySample] else {
          continuation.resume(returning: [])
          return
        }

        let mapped = samples.map { sample in
          Sample(value: sample.quantity.doubleValue(for: type.unit), date: sample.endDate)
        }

        continuation.resume(returning: mapped)
      }
      store.execute(query)
    }
  }

  private func fetchHeartRateData(completion: @escaping HKObserverQueryCompletionHandler) {
    let query = HKAnchoredObjectQuery(
      type: HKQuantityType(.heartRate),
      predicate: nil,
      anchor: anchor,
      limit: HKObjectQueryNoLimit
    ) { [weak self] _, samples, _, newAnchor, _ in
      guard let self, let newestSample = samples?.last as? HKQuantitySample else {
        return
      }

      self.heartRateAnchor = newAnchor
      self.heartRate = newestSample.quantity.doubleValue(for: bpm)

      completion()
    }

    store.execute(query)
  }

  private func fetchStatistics(
    type: StatisticsType,
    quantityType: HKQuantityType,
    unit: HKUnit,
    from: Date,
    to: Date
  ) async throws -> Double {
    return try await withCheckedThrowingContinuation { continuation in
      let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
      let query = HKStatisticsQuery(
        quantityType: quantityType,
        quantitySamplePredicate: predicate,
        options: type.healthKitType
      ) { _, statistics, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        let value = switch type {
        case .cumulativeSum:
          statistics?.sumQuantity()?.doubleValue(for: unit)
        case .average:
          statistics?.averageQuantity()?.doubleValue(for: unit)
        }
        guard let value else {
          continuation.resume(throwing: ContentViewModelError.missingValue)
          return
        }

        continuation.resume(returning: value)
      }
      store.execute(query)
    }
  }
}
