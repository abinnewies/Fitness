//
//  Summary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

struct Summary {
  let range: SummaryRange
  let caloriesBurned: Int?
  let hrv: Int?
  let steps: Int?
  let workouts: [WorkoutSummary]
}
