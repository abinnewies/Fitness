//
//  WorkoutTypeFilterPopoverView.swift
//  Fitness
//
//  Created by Andreas Binnewies on 11/2/25.
//

import HealthKit
import SwiftUI

struct WorkoutTypeFilterPopoverView: View {
  let availableTypes: [HKWorkoutActivityType]
  @Binding var selectedTypes: Set<HKWorkoutActivityType>

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      ForEach(availableTypes, id: \.rawValue) { type in
        Toggle(isOn: Binding(
          get: {
            selectedTypes.contains(type)
          },
          set: { isOn in
            if isOn {
              selectedTypes.insert(type)
            } else {
              selectedTypes.remove(type)
            }
          }
        )) {
          Text(type.pluralTitle)
            .foregroundColor(.primary)
            .font(.body)
        }
        .toggleStyle(CheckmarkToggleStyle())
      }
    }
  }
}
