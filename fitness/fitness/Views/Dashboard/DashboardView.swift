//
//  DashboardView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/14/25.
//

import Charts
import Combine
import HealthKit
import SwiftUI

struct DashboardView: View {
  typealias SelectWorkoutTypeCallback = (HKWorkoutActivityType) -> Void
  @Environment(\.scenePhase) var scenePhase

  private let healthKitManager: HealthKitManager
  @State private var viewModel: DashboardViewModel
  @Binding private var navigationPath: NavigationPath

  @State private var todaySummary: Summary?
  @State private var yesterdaySummary: Summary?
  @State private var last7DaysSummary: Summary?

  var body: some View {
    ScrollView {
      VStack {
        if let todaySummary {
          ForEach(todaySummary.workouts) { workout in
            WorkoutSummaryView(
              workout: workout,
              healthKitManager: healthKitManager
            )
            .contentShape(Rectangle())
            .onTapGesture {
              selectWorkout(workout)
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
            onSelectWorkout: selectWorkout,
            onSelectWorkoutType: selectWorkoutType
          )
        }

        Spacer().frame(height: 24)

        if let last7DaysSummary {
          SummaryView(
            summary: last7DaysSummary,
            healthKitManager: healthKitManager,
            onSelectWorkout: selectWorkout,
            onSelectWorkoutType: selectWorkoutType
          )
        }
      }
      .padding(16)
      .transition(.slide)
    }
    .navigationTitle("Dashboard")
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

  init(navigationPath: Binding<NavigationPath>, healthKitManager: HealthKitManager) {
    _navigationPath = navigationPath
    self.healthKitManager = healthKitManager
    viewModel = DashboardViewModel(healthKitManager: healthKitManager)
  }

  private func selectWorkout(_ workout: HKWorkout) {
    UISelectionFeedbackGenerator().selectionChanged()
    navigationPath.append(NavigationDestination.workoutDetails(workout))
  }

  private func selectWorkoutType(_ workoutType: HKWorkoutActivityType) {
    UISelectionFeedbackGenerator().selectionChanged()
    navigationPath.append(NavigationDestination.workoutList(workoutType))
  }
}
