//
//  WorkoutSummary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

enum WorkoutSummary: Identifiable {
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
}
