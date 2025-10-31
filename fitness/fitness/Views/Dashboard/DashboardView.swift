//
//  DashboardView.swift
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
  @State private var navigationPath = NavigationPath()

  @State private var todaySummary: Summary?
  @State private var yesterdaySummary: Summary?
  @State private var last7DaysSummary: Summary?

  var body: some View {
    NavigationStack(path: $navigationPath) {
      ScrollView {
        VStack {
          if let todaySummary {
            ForEach(todaySummary.workouts) { workout in
              WorkoutSummaryView(
                workout: workout,
                healthKitManager: healthKitManager
              )
              .onTapGesture {
                UISelectionFeedbackGenerator().selectionChanged()
                navigationPath.append(NavigationDestination.workoutDetails(workout))
              }
            }

            LargeSummaryView(
              summary: todaySummary,
              healthKitManager: healthKitManager
            )
          }

          Spacer().frame(height: 24)

          if let yesterdaySummary {
            SummaryView(
              summary: yesterdaySummary,
              healthKitManager: healthKitManager,
              navigationPath: $navigationPath
            )
          }

          Spacer().frame(height: 24)

          if let last7DaysSummary {
            SummaryView(
              summary: last7DaysSummary,
              healthKitManager: healthKitManager,
              navigationPath: $navigationPath
            )
          }
        }
        .padding(16)
        .transition(.slide)
      }
      .navigationTitle("Dashboard")
      .navigationDestination(for: NavigationDestination.self) { destination in
        switch destination {
        case let .workoutDetails(workout):
          WorkoutDetailsView(workout: workout, healthKitManager: healthKitManager)
        case let .workoutList(workoutType):
          WorkoutListView(navigationPath: $navigationPath, healthKitManager: healthKitManager, workoutType: workoutType)
        }
      }
    }
    .onChange(of: scenePhase) {
      if scenePhase == .active {
        Task {
          do {
            try await healthKitManager.requestHealthKitAuthorization()
            let todaySummary = await viewModel.fetchSummary(forRange: .today)
            let yesterdaySummary = await viewModel.fetchSummary(forRange: .yesterday)
            let last7DaysSummary = await viewModel.fetchSummary(forRange: .last7Days)

            // Set these all at the same time after everything has loaded to prevent them from rendering
            // at different times. Also we only animate after the first load.
            if self.todaySummary != nil, self.yesterdaySummary != nil, self.last7DaysSummary != nil {
              withAnimation {
                self.todaySummary = todaySummary
                self.yesterdaySummary = yesterdaySummary
                self.last7DaysSummary = last7DaysSummary
              }
            } else {
              self.todaySummary = todaySummary
              self.yesterdaySummary = yesterdaySummary
              self.last7DaysSummary = last7DaysSummary
            }
          } catch {}
        }
      }
    }
  }

  init(healthKitManager: HealthKitManager) {
    self.healthKitManager = healthKitManager
    viewModel = DashboardViewModel(healthKitManager: healthKitManager)
  }
}
