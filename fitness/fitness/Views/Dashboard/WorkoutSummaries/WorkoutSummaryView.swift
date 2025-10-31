//
//  WorkoutSummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import HealthKit
import MapKit
import SwiftUI

struct WorkoutSummaryView: View {
  let workout: HKWorkout
  let healthKitManager: HealthKitManager

  var body: some View {
    HStack(alignment: .top) {
      VStack(spacing: 8) {
        MetricLabel(metric: workout.workoutActivityType)
          .frame(maxWidth: .infinity, alignment: .leading)

        Spacer(minLength: 0)

        if let distanceMeters = workout.distanceMeters {
          let distanceMiles = distanceMeters.milesFromMeters
          MetricValue(value: String(format: "%.2f", distanceMiles), unit: "miles")
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.all, 12)

      WorkoutMap(workout: workout, healthKitManager: healthKitManager, displayHeatmap: false)
//        .mask(
//          LinearGradient(
//            gradient: Gradient(stops: [
//              .init(color: .clear, location: 0.0),
//              .init(color: .black, location: 0.5),
//              .init(color: .black, location: 1.0),
//            ]),
//            startPoint: .leading,
//            endPoint: .trailing
//          )
//        )
        .clipShape(.rect(
          topLeadingRadius: 12,
          bottomLeadingRadius: 12,
          bottomTrailingRadius: 12,
          topTrailingRadius: 12
        ))
    }
    .padding(.all, 4)
    .background(Color(uiColor: .secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}
