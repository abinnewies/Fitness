//
//  RunSummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import MapKit
import SwiftUI

struct RunSummaryView: View {
  let runSummary: RunSummary

  @State private var mapPosition: MapCameraPosition = .automatic

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      VStack(spacing: 8) {
        HStack {
          Label("Run", systemImage: "figure.run")
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Spacer()

        MetricValue(value: runSummary.duration.durationFormatted, unit: nil)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, -4)

        if let distanceMeters = runSummary.distanceMeters {
          let distanceMiles = distanceMeters.milesFromMeters
          MetricValue(value: String(format: "%.1f", distanceMiles), unit: "miles")
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.all, 16)

      // Map on the right
      if let region = runSummary.routeRegion {
        Group {
          Map(position: $mapPosition) {
            MapPolyline(coordinates: runSummary.routeCoordinates)
              .stroke(
                .blue,
                style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
              )
            if let start = runSummary.routeCoordinates.first {
              Annotation("Start", coordinate: start) {
                ZStack {
                  Circle().fill(.green).frame(width: 10, height: 10)
                  Circle().stroke(.white, lineWidth: 2).frame(width: 10, height: 10)
                }
              }
            }
            if let end = runSummary.routeCoordinates.last {
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
          .compositingGroup()
          .mask(
            LinearGradient(
              colors: [
                Color.black.opacity(0),
                Color.black.opacity(0.8),
                Color.black,
                Color.black,
              ],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
        }
        .frame(minWidth: 180)
        .aspectRatio(1.3, contentMode: .fit)
      }
    }
    .background(Rectangle().fill(Color(uiColor: .secondarySystemBackground)))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}
