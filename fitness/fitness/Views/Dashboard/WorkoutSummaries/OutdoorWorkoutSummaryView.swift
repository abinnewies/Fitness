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

  var body: some View {
    HStack(alignment: .top) {
      VStack(spacing: 8) {
        MetricLabel(metric: outdoorWorkoutSummary.summaryMetric)
          .frame(maxWidth: .infinity, alignment: .leading)

        Spacer(minLength: 0)

        let distanceMiles = outdoorWorkoutSummary.distanceMeters.milesFromMeters
        MetricValue(value: String(format: "%.2f", distanceMiles), unit: "miles")
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.all, 12)

      WorkoutMap(workout: outdoorWorkoutSummary.workout, healthKitManager: healthKitManager)
        .mask(
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .clear, location: 0.0),
              .init(color: .black, location: 0.2),
              .init(color: .black, location: 1.0),
            ]),
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding(.all, 4)
    .background(Color(uiColor: .secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}
