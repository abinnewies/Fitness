//
//  TimeInterval+Formatting.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import Foundation

extension TimeInterval {
  var durationFormatted: String {
    let total = Int(self)
    let hours = total / 3600
    let minutes = (total % 3600) / 60
    let seconds = total % 60
    if hours > 0 {
      return String(format: "%dh %dm %ds", hours, minutes, seconds)
    } else {
      return String(format: "%dm %ds", minutes, seconds)
    }
  }

  var durationFormattedShort: String {
    let total = Int(self)
    let hours = total / 3600
    let minutes = (total % 3600) / 60
    let seconds = total % 60
    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
      return String(format: "%d:%02d", minutes, seconds)
    }
  }
}
