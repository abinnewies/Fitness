//
//  Date+Formatting.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/30/25.
//

import Foundation

extension Date {
  var formattedTime: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm"
    return formatter.string(from: self)
  }

  var formattedAmPm: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "a"
    return formatter.string(from: self)
  }
}
