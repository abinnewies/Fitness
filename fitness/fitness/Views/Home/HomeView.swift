//
//  HomeView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 11/1/25.
//

import HealthKit
import SwiftUI

struct HomeView: View {
  private let healthKitManager = HealthKitManager()
  @State private var selectedTab = Tab.dashboard
  @State private var navigationPath = NavigationPath()
  @State private var hideTabBar = false

  private enum Tab {
    case dashboard
    case workouts
  }

  @ViewBuilder
  private func navigationDestination(destination: NavigationDestination) -> some View {
    switch destination {
    case let .workoutDetails(workout):
      WorkoutDetailsView(workout: workout, healthKitManager: healthKitManager)
    case let .workoutList(workoutActivityType):
      WorkoutListView(
        navigationPath: $navigationPath,
        selectedType: workoutActivityType,
        healthKitManager: healthKitManager
      )
    }
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      NavigationStack(path: $navigationPath) {
        DashboardView(navigationPath: $navigationPath, healthKitManager: healthKitManager)
          .navigationDestination(for: NavigationDestination.self, destination: navigationDestination)
      }
      .tabItem {
        Image(systemName: "heart.fill")
      }
      .tag(Tab.dashboard)
      .toolbar(hideTabBar ? .hidden : .visible, for: .tabBar)

      NavigationStack(path: $navigationPath) {
        WorkoutListView(navigationPath: $navigationPath, healthKitManager: healthKitManager)
          .navigationDestination(for: NavigationDestination.self, destination: navigationDestination)
      }
      .tabItem {
        Image(systemName: "figure.run")
      }
      .tag(Tab.workouts)
      .toolbar(hideTabBar ? .hidden : .visible, for: .tabBar)
    }
    .onChange(of: navigationPath) {
      withAnimation {
        hideTabBar = !navigationPath.isEmpty
      }
    }
  }
}
