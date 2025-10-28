//
//  OutdoorWorkoutSummary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import Foundation
import HealthKit

protocol OutdoorWorkoutSummary {
  var name: String { get }
  var symbol: SFSymbolName { get }
  var distanceMeters: Double { get }
  var duration: TimeInterval { get }
  var elevationAscendedMeters: Double? { get }
  var workout: HKWorkout { get }
}
