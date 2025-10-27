//
//  ContentView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/14/25.
//

import Charts
import Combine
import SwiftUI

struct DashboardView: View {
  @Environment(\.scenePhase) var scenePhase

  private let healthKitManager: HealthKitManager
  @State private var viewModel: DashboardViewModel

  @State private var todaySummary: Summary?
  @State private var yesterdaySummary: Summary?
  @State private var last7DaysSummary: Summary?

  var body: some View {
    ScrollView {
      VStack {
        if let todaySummary {
          ForEach(todaySummary.runs) { runSummary in
            RunSummaryView(runSummary: runSummary)
          }

          LargeSummaryView(summary: todaySummary)
        }

        Spacer().frame(height: 24)

        if let yesterdaySummary {
          SummaryView(summary: yesterdaySummary)
        }

        Spacer().frame(height: 24)

        if let last7DaysSummary {
          SummaryView(summary: last7DaysSummary)
        }
      }
      .padding(16)
    }
    .onChange(of: scenePhase) {
      if scenePhase == .active {
        Task {
          do {
            try await healthKitManager.requestHealthKitAuthorization()
            todaySummary = try await viewModel.fetchSummary(forRange: .today)
            yesterdaySummary = try await viewModel.fetchSummary(forRange: .yesterday)
            last7DaysSummary = try await viewModel.fetchSummary(forRange: .last7Days)
          } catch {
            print(error)
          }
        }
      }
    }
  }

  init(healthKitManager: HealthKitManager) {
    self.healthKitManager = healthKitManager
    viewModel = DashboardViewModel(healthKitManager: healthKitManager)
  }
}
