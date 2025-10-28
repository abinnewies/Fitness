//
//  SmallOutdoorWorkoutSummaryView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/28/25.
//

import MapKit
import SwiftUI

struct SmallOutdoorWorkoutSummaryView: View {
  let outdoorWorkoutSummary: OutdoorWorkoutSummary
  let healthKitManager: HealthKitManager

  var body: some View {
    HStack {
      Label(outdoorWorkoutSummary.name, symbol: outdoorWorkoutSummary.symbol)
        .frame(maxWidth: .infinity, alignment: .leading)

      Spacer()

      let distanceMiles = outdoorWorkoutSummary.distanceMeters.milesFromMeters
      MetricValue(value: String(format: "%.2f", distanceMiles), unit: "miles")
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.all, 16)
    .background(Color(uiColor: .secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}
