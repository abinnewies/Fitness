//
//  LargeSummaryRow.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/25/25.
//

import Charts
import SwiftUI

struct LargeSummaryRow: View {
  let summaryDate: Date
  let values: [SummaryRowValue]
  let healthKitManager: HealthKitManager
  let healthSummaryMetric: HealthSummaryMetric

  var body: some View {
    let startOfToday = Calendar.current.startOfDay(for: Date())
    let endOfToday = startOfToday.addingTimeInterval(86400)
    HStack(alignment: .bottom) {
      VStack(spacing: 8) {
        MetricLabel(summaryMetric: healthSummaryMetric)
          .frame(maxWidth: .infinity, alignment: .leading)

        Spacer(minLength: 8)

        HStack(spacing: 8) {
          ForEach(values) { value in
            MetricValue(value: value.value, unit: value.unit)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      switch healthSummaryMetric {
      case .caloriesBurned:
        SmallCaloriesGraph(
          from: startOfToday,
          to: endOfToday,
          currentDate: summaryDate,
          healthKitManager: healthKitManager,
          stride: .hour(1)
        )
      case .heartRate:
        SmallHeartRateGraph(
          from: startOfToday,
          to: endOfToday,
          currentDate: summaryDate,
          healthKitManager: healthKitManager,
          stride: .hour(1)
        )
      case .hikes, .runs:
        Color.clear
      case .stepCount:
        SmallStepsGraph(
          from: startOfToday,
          to: endOfToday,
          currentDate: summaryDate,
          healthKitManager: healthKitManager,
          stride: .hour(1)
        )
      }
    }
    .padding(.all, 16)
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))
  }
}
