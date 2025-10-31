//
//  NavigationDestination.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/30/25.
//

import Foundation
import HealthKit

enum NavigationDestination: Hashable {
  case workoutDetails(HKWorkout)
  case workoutList(HKWorkoutActivityType?)
}
