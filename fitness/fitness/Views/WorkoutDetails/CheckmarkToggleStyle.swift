//
//  CheckmarkToggleStyle.swift
//  Fitness
//
//  Created by Andreas Binnewies on 11/2/25.
//

import SwiftUI

struct CheckmarkToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button {
      configuration.isOn.toggle()
    } label: {
      HStack {
        Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
          .foregroundColor(configuration.isOn ? .accentColor : .gray)
          .font(.body)
        configuration.label
      }
    }
  }
}
