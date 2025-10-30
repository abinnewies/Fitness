//
//  RunSummary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import HealthKit

struct RunSummary: Identifiable, OutdoorWorkoutSummary, Hashable {
  let summaryMetric = HealthSummaryMetric.runs(1)
  let id: String
  let distanceMeters: Double
  let duration: TimeInterval
  let elevationAscendedMeters: Double?
  let workout: HKWorkout
}
