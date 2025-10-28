//
//  HikeSummary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import Foundation
import HealthKit

struct HikeSummary: Identifiable, OutdoorWorkoutSummary {
  let name = "Hike"
  let symbol = SFSymbolName.figureWalk
  let id: String
  let distanceMeters: Double
  let duration: TimeInterval
  let elevationAscendedMeters: Double?
  let workout: HKWorkout
}
