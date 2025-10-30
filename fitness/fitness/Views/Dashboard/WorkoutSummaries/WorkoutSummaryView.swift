//
//  WorkoutSummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import SwiftUI

struct WorkoutSummaryView: View {
  let workoutSummary: WorkoutSummary
  let healthKitManager: HealthKitManager

  var body: some View {
    switch workoutSummary {
    case let .run(runSummary):
      OutdoorWorkoutSummaryView(outdoorWorkoutSummary: runSummary, healthKitManager: healthKitManager)
    case let .hike(hikeSummary):
      OutdoorWorkoutSummaryView(outdoorWorkoutSummary: hikeSummary, healthKitManager: healthKitManager)
    }
  }
}
