//
//  FitnessApp.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/14/25.
//

import SwiftUI

@main
struct FitnessApp: App {
  var body: some Scene {
    WindowGroup {
      DashboardView(healthKitManager: .init())
    }
  }
}
