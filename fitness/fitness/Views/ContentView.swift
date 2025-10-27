//
//  ContentView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/14/25.
//

import Charts
import Combine
import SwiftUI

struct ContentView: View {
  @Environment(\.scenePhase) var scenePhase

  @State var viewModel = ContentViewModel()
  @State var todaySummary: Summary?
  @State var yesterdaySummary: Summary?
  @State var last7DaysSummary: Summary?

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
    .onChange(of: scenePhase) { _, newPhase in
      if newPhase == .active {
        Task {
          do {
            try await viewModel.requestHealthKitAuthorization()
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
}

#Preview {
  ContentView()
}
