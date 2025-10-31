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
  var groupedWorkouts: [(date: Date, workouts: [HKWorkout])]?

  private let healthKitManager: HealthKitManager

  init(healthKitManager: HealthKitManager) {
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
    groupedWorkouts = orderedDays.map { day in
      let ws = (grouped[day] ?? []).sorted {
        $0.startDate > $1.startDate
      }
      return (day, ws)
    }
  }
}
