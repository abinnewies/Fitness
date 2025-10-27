//
//  Summary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

struct Summary {
  let range: SummaryRange
  let caloriesBurned: Int
  let elevationAscendedMeters: Double?
  let distanceRunMeters: Double?
  let restingHeartRate: Int?
  let steps: Int
  let runs: [RunSummary]
  let calorieSamples: [Int: Sample]
  let stepCountSamples: [Int: Sample]
}
