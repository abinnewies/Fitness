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
  private let supportFiltering: Bool
  private let healthKitManager: HealthKitManager

  @State private var showFilterPopover = false

  var body: some View {
    List {
      ForEach(viewModel.filteredWorkouts, id: \.date) { section in
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
    .listStyle(.plain)
    .listRowSpacing(8)
    .navigationTitle(viewModel.selectedTypes.count == 1 ? viewModel.selectedTypes.first!.pluralTitle : "Workouts")
    .toolbar {
      if supportFiltering, !viewModel.availableTypes.isEmpty {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            showFilterPopover.toggle()
          }) {
            Image(systemName: "line.3.horizontal.decrease")
          }
          .popover(isPresented: $showFilterPopover, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            WorkoutTypeFilterPopoverView(
              availableTypes: viewModel.availableTypes,
              selectedTypes: $viewModel.selectedTypes
            )
            .padding(24)
            .presentationCompactAdaptation(.popover)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
          }
        }
      }
    }
    .task {
      try? await viewModel.fetchWorkouts()
    }
  }

  init(
    navigationPath: Binding<NavigationPath>,
    selectedType: HKWorkoutActivityType? = nil,
    healthKitManager: HealthKitManager
  ) {
    _navigationPath = navigationPath
    self.healthKitManager = healthKitManager
    supportFiltering = selectedType == nil
    viewModel = WorkoutListViewModel(
      selectedTypes: selectedType != nil ? [selectedType!] : [],
      healthKitManager: healthKitManager
    )
  }
}
