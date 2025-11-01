//
//  DateComponents+TimeInterval.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/31/25.
//

import Foundation

extension DateComponents {
  var timeInterval: TimeInterval {
    TimeInterval(second ?? 0) + TimeInterval(minute ?? 0) * 60 + TimeInterval(hour ?? 0) * 3600 +
      TimeInterval(day ?? 0) *
      86400
  }
}
