//
//  View+Conditionals.swift
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

  @ViewBuilder
  func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
    if condition { transform(self) }
    else { self }
  }
}
