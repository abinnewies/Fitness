//
//  WorkoutListViewModel.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/30/25.
//

import HealthKit
import SwiftUI

@Observable
class WorkoutListViewModel {
  typealias GroupedWorkouts = (date: Date, workouts: [HKWorkout])
  var filteredWorkouts: [GroupedWorkouts] = []

  var selectedTypes: Set<HKWorkoutActivityType> {
    didSet {
      filterWorkouts()
    }
  }

  var availableTypes: [HKWorkoutActivityType] {
    let allTypes = allWorkouts.flatMap {
      $0.workouts.map {
        $0.workoutActivityType
      }
    }
    let unique = Set(allTypes).intersection(supportedTypes)
    return Array(unique).sorted { $0.rawValue < $1.rawValue }
  }

  private var allWorkouts: [GroupedWorkouts] = []

  private let supportedTypes = Set([HKWorkoutActivityType.running, HKWorkoutActivityType.hiking])

  private let healthKitManager: HealthKitManager

  init(selectedTypes: Set<HKWorkoutActivityType>, healthKitManager: HealthKitManager) {
    self.selectedTypes = selectedTypes
    self.healthKitManager = healthKitManager
  }

  func fetchWorkouts(ofType type: HKWorkoutActivityType? = nil) async throws {
    let endDate = Date()
    guard let startDate = Calendar.current.date(byAdding: .day, value: -365, to: endDate) else {
      return
    }

    let workouts = try await healthKitManager.fetchWorkouts(from: startDate, to: endDate, ofType: type)

    let calendar = Calendar.current
    let grouped = Dictionary(grouping: workouts) { workout in
      calendar.startOfDay(for: workout.startDate)
    }

    let orderedDays = grouped.keys.sorted(by: >)
    allWorkouts = orderedDays.map { day in
      let ws = (grouped[day] ?? []).sorted {
        $0.startDate > $1.startDate
      }
      return (day, ws)
    }
    filterWorkouts()
  }

  private func filterWorkouts() {
    let filteredWorkouts = allWorkouts.compactMap {
      let workouts = $0.workouts.filter {
        selectedTypes.isEmpty || selectedTypes.contains($0.workoutActivityType)
      }
      return workouts.isEmpty ? nil : (date: $0.date, workouts: workouts)
    }
    self.filteredWorkouts = filteredWorkouts
  }
}
