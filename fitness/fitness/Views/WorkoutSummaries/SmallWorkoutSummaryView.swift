//
//  SmallWorkoutSummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/28/25.
//

import SwiftUI

struct SmallWorkoutSummaryView: View {
  let workoutSummary: WorkoutSummary
  let healthKitManager: HealthKitManager

  var body: some View {
    switch workoutSummary {
    case let .run(runSummary):
      SmallOutdoorWorkoutSummaryView(outdoorWorkoutSummary: runSummary, healthKitManager: healthKitManager)
    case let .hike(hikeSummary):
      SmallOutdoorWorkoutSummaryView(outdoorWorkoutSummary: hikeSummary, healthKitManager: healthKitManager)
    }
  }
}
