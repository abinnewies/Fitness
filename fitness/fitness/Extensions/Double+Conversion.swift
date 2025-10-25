//
//  Double+Conversion.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/24/25.
//

extension Double {
  var milesFromMeters: Double {
    self / 1609.344
  }

  var feetFromMeters: Double {
    self * 3.281
  }
}
