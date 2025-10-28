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
}
