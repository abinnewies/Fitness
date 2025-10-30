//
//  WorkoutSummary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import HealthKit

enum WorkoutSummary: Identifiable, Hashable {
  case run(RunSummary)
  case hike(HikeSummary)

  var id: String {
    switch self {
    case let .run(summary):
      summary.id
    case let .hike(summary):
      summary.id
    }
  }

  var runSummary: RunSummary? {
    if case let .run(runSummary) = self {
      return runSummary
    }
    return nil
  }

  var hikeSummary: HikeSummary? {
    if case let .hike(hikeSummary) = self {
      return hikeSummary
    }
    return nil
  }

  var workout: HKWorkout {
    switch self {
    case let .run(runSummary):
      runSummary.workout

    case let .hike(hikeSummary):
      hikeSummary.workout
    }
  }
}
