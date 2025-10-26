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

struct HeartRateSample {
  let heartRate: Double
  let date: Date
}

enum ContentViewModelError: Error {
  case missingValue
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
      runs: await fetchRunSummaries(forRange: summaryRange)
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

  func fetchHourlyHeartRateDate() async throws -> [HourlyHeartRateSample] {
    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)
    let heartRateSamples = try await fetchHeartRateSamples(from: startOfDay, to: now)

    var hourlySamples: [Int: HourlyHeartRateSample] = [:]
    for sample in heartRateSamples {
      let hour = calendar.component(.hour, from: sample.date)
      if let existing = hourlySamples[hour] {
        hourlySamples[hour] = HourlyHeartRateSample(
          minHeartRate: min(existing.minHeartRate, sample.heartRate),
          maxHeartRate: max(existing.maxHeartRate, sample.heartRate),
          hour: existing.hour
        )
      } else {
        hourlySamples[hour] = HourlyHeartRateSample(
          minHeartRate: sample.heartRate,
          maxHeartRate: sample.heartRate,
          hour: sample.date
        )
      }
    }

    return Array(hourlySamples.values)
  }

  func fetchHeartRateSamples(from: Date, to: Date) async throws -> [HeartRateSample] {
    let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(
        sampleType: HKQuantityType(.heartRate),
        predicate: predicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: [sortDescriptor]
      ) { [weak self] _, samples, error in
        guard let self else {
          return
        }

        if let error {
          continuation.resume(throwing: error)
          return
        }

        guard let samples = samples as? [HKQuantitySample] else {
          return
        }

        let heartRateSamples = samples.map { sample in
          let value = sample.quantity.doubleValue(for: self.bpm)
          return HeartRateSample(heartRate: value, date: sample.endDate)
        }
        continuation.resume(returning: heartRateSamples)
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
