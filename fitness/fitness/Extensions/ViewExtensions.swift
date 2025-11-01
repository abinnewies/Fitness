//
//  ViewExtensions.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/31/25.
//

import SwiftUI

extension View {
  @ViewBuilder
  func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
    if let value {
      transform(self, value)
    } else {
      self
    }
  }
}
