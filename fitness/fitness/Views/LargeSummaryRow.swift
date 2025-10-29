//
//  LargeSummaryRow.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/25/25.
//

import Charts
import SwiftUI

struct LargeSummaryRow: View {
  let symbol: SFSymbolName
  let title: String
  let value: String
  let unit: String
  let healthKitManager: HealthKitManager
  let healthSummaryMetric: HealthSummaryMetric?

  var body: some View {
    let startOfToday = Calendar.current.startOfDay(for: Date())
    let endOfToday = startOfToday.addingTimeInterval(86400)
    HStack(alignment: .bottom) {
      VStack(spacing: 8) {
        MetricLabel(symbol: symbol, title: title)
          .frame(maxWidth: .infinity, alignment: .leading)

        Spacer(minLength: 8)

        MetricValue(value: value, unit: unit)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      if let healthSummaryMetric {
        switch healthSummaryMetric {
        case .caloriesBurned:
          SmallCaloriesGraph(from: startOfToday, to: endOfToday, healthKitManager: healthKitManager, stride: .hour(1))
        case .heartRate:
          SmallHeartRateGraph(from: startOfToday, to: endOfToday, healthKitManager: healthKitManager, stride: .hour(1))
        case .hrv:
          SmallHRVGraph(from: startOfToday, to: endOfToday, healthKitManager: healthKitManager, stride: .hour(1))
        case .stepCount:
          SmallStepsGraph(from: startOfToday, to: endOfToday, healthKitManager: healthKitManager, stride: .hour(1))
        }
      }
    }
    .padding(.all, 16)
    .background(RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .secondarySystemBackground)))
  }
}
