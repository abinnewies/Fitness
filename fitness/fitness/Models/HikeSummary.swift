//
//  HikeSummary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import Foundation
import HealthKit

struct HikeSummary: Identifiable, OutdoorWorkoutSummary, Hashable {
  let summaryMetric = HealthSummaryMetric.hikes(1)
  let id: String
  let distanceMeters: Double
  let duration: TimeInterval
  let elevationAscendedMeters: Double?
  let workout: HKWorkout
}
