//
//  EnvironmentVariables.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import SwiftUI

private struct HealthKitManagerKey: EnvironmentKey {
  static let defaultValue: HealthKitManager = .init()
}

extension EnvironmentValues {
  var healthKitManager: HealthKitManager {
    get { self[HealthKitManagerKey.self] }
    set { self[HealthKitManagerKey.self] = newValue }
  }
}
