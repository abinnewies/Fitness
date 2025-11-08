//
//  HeartRateZone.swift
//  Fitness
//
//  Created by Andreas Binnewies on 11/7/25.
//

import Charts
import SwiftUI

struct HeartRateZone: Hashable, Identifiable {
  static let zones: [HeartRateZone] = [
    .init(zoneNumber: 1, minHeartRate: nil, maxHeartRate: 128, color: .zone1),
    .init(zoneNumber: 2, minHeartRate: 129, maxHeartRate: 141, color: .zone2),
    .init(zoneNumber: 3, minHeartRate: 142, maxHeartRate: 153, color: .zone3),
    .init(zoneNumber: 4, minHeartRate: 154, maxHeartRate: 165, color: .zone4),
    .init(zoneNumber: 5, minHeartRate: 166, maxHeartRate: nil, color: .zone5),
  ]

  let zoneNumber: Int
  let minHeartRate: Double?
  let maxHeartRate: Double?
  let color: Color

  var id: Int {
    zoneNumber
  }

  func containsHeartRate(_ heartRate: Double) -> Bool {
    if let minHeartRate, let maxHeartRate {
      minHeartRate <= heartRate && heartRate <= maxHeartRate
    } else if let minHeartRate {
      minHeartRate <= heartRate
    } else if let maxHeartRate {
      heartRate <= maxHeartRate
    } else {
      false
    }
  }
}

extension Array where Element == HeartRateZone {
  func zone(forHeartRate heartRate: Double) -> HeartRateZone {
    HeartRateZone.zones.first(where: { $0.containsHeartRate(heartRate) }) ?? HeartRateZone.zones.first!
  }
}
