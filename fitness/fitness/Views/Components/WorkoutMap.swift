//
//  WorkoutMap.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/30/25.
//

import HealthKit
import MapKit
import SwiftUI

struct WorkoutMap: View {
  let workout: HKWorkout
  let healthKitManager: HealthKitManager

  @State private var routePoints: [RoutePoint] = []
  @State private var mapPosition: MapCameraPosition = .automatic

  var body: some View {
    Group {
      if let region = routePoints.routeRegion {
        Map(position: $mapPosition) {
          MapPolyline(coordinates: routePoints.routeCoordinates)
            .stroke(
              .blue,
              style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            )
          if let start = routePoints.routeCoordinates.first {
            Annotation("Start", coordinate: start) {
              ZStack {
                Circle().fill(.green).frame(width: 10, height: 10)
                Circle().stroke(.white, lineWidth: 2).frame(width: 10, height: 10)
              }
            }
          }
          if let end = routePoints.routeCoordinates.last {
            Annotation("End", coordinate: end) {
              ZStack {
                Circle().fill(.red).frame(width: 10, height: 10)
                Circle().stroke(.white, lineWidth: 2).frame(width: 10, height: 10)
              }
            }
          }
        }
        .mapStyle(.standard)
        .allowsHitTesting(false)
        .onAppear {
          mapPosition = .region(region)
        }
      } else {
        // Placeholder so there's not a jump when the route data arrives
        Color.clear
      }
    }
    .task {
      do {
        let routes = try await healthKitManager.fetchRoutes(for: workout)
        guard let route = routes.first else {
          routePoints = []
          return
        }

        routePoints = try await healthKitManager.fetchRoutePoints(for: route)
      } catch {
        routePoints = []
      }
    }
  }
}
