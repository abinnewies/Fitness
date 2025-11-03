//
//  WorkoutDetailsViewModel.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/31/25.
//

import CoreLocation
import HealthKit
import SwiftUI

@Observable
class WorkoutDetailsViewModel {
  private(set) var hasRoute = false
  private(set) var cityName: String?
  private(set) var hasLoaded = false
  private let workout: HKWorkout
  private let healthKitManager: HealthKitManager
  private let geocoder = CLGeocoder()

  init(workout: HKWorkout, healthKitManager: HealthKitManager) {
    self.workout = workout
    self.healthKitManager = healthKitManager
  }

  func loadData() async throws {
    let routes = try? await healthKitManager.fetchRoutes(for: workout)
    hasRoute = routes?.isEmpty == false
    if let route = routes?.first,
       let routePoints = try? await healthKitManager.fetchRoutePoints(for: route),
       let routePoint = routePoints.first
    {
      cityName = try? await reverseGeocodeCity(for: routePoint)
    }
    hasLoaded = true
  }

  private func reverseGeocodeCity(for location: CLLocation) async throws -> String? {
    let placemarks = try? await geocoder.reverseGeocodeLocation(location)
    guard let placemark = placemarks?.first else {
      return nil
    }
    return placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea
  }
}
