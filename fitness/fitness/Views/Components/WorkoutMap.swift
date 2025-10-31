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
  let displayHeatmap: Bool

  @State private var routePoints: [CLLocation] = []
  @State private var routeColors: Gradient = .init(colors: [.accentColor])
  @State private var mapPosition: MapCameraPosition = .automatic

  var body: some View {
    Group {
      if let region = routePoints.routeRegion {
        Map(position: $mapPosition) {
          MapPolyline(coordinates: routePoints.routeCoordinates)
            .stroke(
              routeColors,
              style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
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
        .allowsHitTesting(false)
        .onAppear {
          mapPosition = .region(region)
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: []))
      } else {
        // Placeholder so the UI doesn't jump when the data arrives
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

        let routePoints = try await healthKitManager.fetchRoutePoints(for: route)
        if displayHeatmap {
          let heatmapGradientGenerator = HeatmapGradientGenerator()
          routeColors = heatmapGradientGenerator.heatmapGradient(for: routePoints, defaultColor: .accentColor)
        } else {
          routeColors = Gradient(colors: [.accentColor])
        }
        self.routePoints = routePoints
      } catch {
        routePoints = []
      }
    }
  }
}
