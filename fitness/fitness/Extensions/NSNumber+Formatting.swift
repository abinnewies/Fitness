//
//  NSNumber+Formatting.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/24/25.
//

import Foundation

extension Int {
  var commaDelimitedString: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: self)) ?? String(self)
  }
}
