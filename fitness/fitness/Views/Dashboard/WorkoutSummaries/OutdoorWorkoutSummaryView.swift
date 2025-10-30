//
//  OutdoorWorkoutSummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import MapKit
import SwiftUI

struct OutdoorWorkoutSummaryView: View {
  let outdoorWorkoutSummary: OutdoorWorkoutSummary
  let healthKitManager: HealthKitManager

  @State private var routePoints: [RoutePoint] = []
  @State private var mapPosition: MapCameraPosition = .automatic

  var body: some View {
    HStack(alignment: .top) {
      VStack(spacing: 8) {
        MetricLabel(summaryMetric: outdoorWorkoutSummary.summaryMetric)
          .frame(maxWidth: .infinity, alignment: .leading)

        Spacer(minLength: 0)

        let distanceMiles = outdoorWorkoutSummary.distanceMeters.milesFromMeters
        MetricValue(value: String(format: "%.2f", distanceMiles), unit: "miles")
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.all, 12)

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
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .onAppear {
            mapPosition = .region(region)
          }
          .frame(maxHeight: .infinity)
        } else {
          // Placeholder so there's not a jump when the route data arrives
          Color.clear
        }
      }
    }
    .padding(.all, 4)
    .background(Color(uiColor: .secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .task {
      do {
        let routes = try await healthKitManager.fetchRoutes(for: outdoorWorkoutSummary.workout)
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
