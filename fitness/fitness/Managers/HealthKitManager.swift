//
//  HealthKitManager.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/16/25.
//

import Combine
import CoreLocation
import HealthKit
import SwiftUI

enum HealthKitManagerError: Error {
  case missingValue
}

enum StatisticsType {
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

enum QuantityType: Sendable {
  case activeEnergyBurned
  case basalEnergyBurned
  case heartRate
  case hrv
  case restingHeartRate
  case stepCount

  var type: HKQuantityType {
    switch self {
    case .activeEnergyBurned:
      HKQuantityType(.activeEnergyBurned)
    case .basalEnergyBurned:
      HKQuantityType(.basalEnergyBurned)
    case .heartRate:
      HKQuantityType(.heartRate)
    case .hrv:
      HKQuantityType(.heartRateVariabilitySDNN)
    case .restingHeartRate:
      HKQuantityType(.restingHeartRate)
    case .stepCount:
      HKQuantityType(.stepCount)
    }
  }

  var unit: HKUnit {
    switch self {
    case .activeEnergyBurned, .basalEnergyBurned:
      HKUnit.kilocalorie()
    case .hrv:
      HKUnit.secondUnit(with: .milli)
    case .stepCount:
      HKUnit.count()
    case .restingHeartRate, .heartRate:
      HKUnit.count().unitDivided(by: HKUnit.minute())
    }
  }
}

@Observable
class HealthKitManager {
  private let store = HKHealthStore()

  private let healthDataTypes: Set<HKObjectType> = [
    HKQuantityType(.heartRate),
    HKQuantityType(.restingHeartRate),
    HKQuantityType(.activeEnergyBurned),
    HKQuantityType(.basalEnergyBurned),
    HKQuantityType(.stepCount),
    HKQuantityType(.heartRateVariabilitySDNN),
    HKObjectType.workoutType(),
    HKSeriesType.workoutRoute(),
  ]

  func requestHealthKitAuthorization() async throws {
    try await store.requestAuthorization(toShare: Set(), read: healthDataTypes)
  }

  func fetchWorkouts(from: Date, to: Date, ofType type: HKWorkoutActivityType? = nil) async throws -> [HKWorkout] {
    let workoutType = HKObjectType.workoutType()

    var subpredicates: [NSPredicate] = [
      HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate),
    ]
    if let type {
      subpredicates.append(HKQuery.predicateForWorkouts(with: type))
    }

    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
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

  func fetchRoutes(for workout: HKWorkout) async throws -> [HKWorkoutRoute] {
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

  func fetchRoutePoints(for route: HKWorkoutRoute) async throws -> [RoutePoint] {
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

  func fetchStatisticsCollection(
    type: QuantityType,
    from: Date,
    to: Date,
    interval _: DateComponents
  ) async throws -> [Int: Double] {
    let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
    let interval = DateComponents(hour: 1)
    let anchorDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: from)!
    let unit = type.unit

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKStatisticsCollectionQuery(
        quantityType: type.type,
        quantitySamplePredicate: predicate,
        options: [.discreteAverage],
        anchorDate: anchorDate,
        intervalComponents: interval
      )

      query.initialResultsHandler = { _, collection, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let collection else {
          continuation.resume(returning: [:])
          return
        }

        var results: [Int: Double] = [:]
        let intervalSeconds = TimeInterval(interval.hour ?? 0) * 3600 + TimeInterval(interval.day ?? 0) * 86400
        for index in stride(
          from: 0,
          to: Int(ceil((to.timeIntervalSince1970 - from.timeIntervalSince1970) / intervalSeconds)),
          by: 1
        ) {
          let date = from.addingTimeInterval(TimeInterval(index) * intervalSeconds)
          if let stats = collection.statistics(for: date),
             let value = stats.averageQuantity()?.doubleValue(for: unit)
          {
            results[index] = value
          }
        }
        continuation.resume(returning: results)
      }

      HKHealthStore().execute(query)
    }
  }

  func fetchSamples(type: QuantityType, from: Date, to: Date) async throws -> [Sample] {
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

  func fetchStatistics(
    type: StatisticsType,
    quantityType: QuantityType,
    from: Date,
    to: Date
  ) async throws -> Double {
    return try await withCheckedThrowingContinuation { continuation in
      let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
      let query = HKStatisticsQuery(
        quantityType: quantityType.type,
        quantitySamplePredicate: predicate,
        options: type.healthKitType
      ) { _, statistics, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        let value = switch type {
        case .cumulativeSum:
          statistics?.sumQuantity()?.doubleValue(for: quantityType.unit)
        case .average:
          statistics?.averageQuantity()?.doubleValue(for: quantityType.unit)
        }

        guard let value else {
          continuation.resume(throwing: HealthKitManagerError.missingValue)
          return
        }

        continuation.resume(returning: value)
      }
      store.execute(query)
    }
  }
}
