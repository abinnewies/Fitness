//
//  Summary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import Foundation

struct Summary {
  let date = Date()
  let range: SummaryRange
  let caloriesBurned: Int?
  let minHeartRate: Int?
  let maxHeartRate: Int?
  let steps: Int?
  let workouts: [WorkoutSummary]
}
