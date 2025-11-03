//
//  NavigationDestination.swift
//  Fitness
//
//  Created by Andreas Binnewies on 11/3/25.
//

import HealthKit

enum NavigationDestination: Hashable {
  case workoutDetails(HKWorkout)
  case workoutList(HKWorkoutActivityType)
}
