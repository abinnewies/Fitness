//
//  WorkoutListView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/30/25.
//

import HealthKit
import SwiftUI

struct WorkoutListView: View {
  @Binding var navigationPath: NavigationPath
  @State private var viewModel: WorkoutListViewModel
  private let healthKitManager: HealthKitManager
  private let workoutType: HKWorkoutActivityType?

  var body: some View {
    Group {
      List {
        if let groupedWorkouts = viewModel.groupedWorkouts {
          ForEach(groupedWorkouts, id: \.date) { section in
            Section(header: Text(section.date, style: .date)) {
              ForEach(section.workouts, id: \.uuid) { workout in
                WorkoutSummaryView(workout: workout, healthKitManager: healthKitManager)
                  .listRowSeparator(.hidden)
                  .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                  .contentShape(Rectangle())
                  .onTapGesture {
                    UISelectionFeedbackGenerator().selectionChanged()
                    navigationPath.append(NavigationDestination.workoutDetails(workout))
                  }
              }
            }
          }
        }
      }
      .listStyle(.plain)
      .listRowSpacing(8)
    }
    .task {
      try? await viewModel.fetchWorkouts(ofType: workoutType)
    }
    .navigationTitle(workoutType == nil ? "Workouts" : workoutType!.pluralTitle)
  }

  init(
    navigationPath: Binding<NavigationPath>,
    healthKitManager: HealthKitManager,
    workoutType: HKWorkoutActivityType? = nil
  ) {
    _navigationPath = navigationPath
    self.healthKitManager = healthKitManager
    viewModel = WorkoutListViewModel(healthKitManager: healthKitManager)
    self.workoutType = workoutType
  }
}
