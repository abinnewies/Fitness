//
//  Summary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import Foundation
import HealthKit

struct Summary: Hashable {
  let date = Date()
  let range: SummaryRange
  let caloriesBurned: Int?
  let minHeartRate: Int?
  let maxHeartRate: Int?
  let restingHeartRate: Int?
  let sleepDuration: TimeInterval?
  let steps: Int?
  let workouts: [HKWorkout]
}
