//
//  HeatmapGradientGenerator.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/30/25.
//

import CoreLocation
import SwiftUI

class HeatmapGradientGenerator {
  private let sampleDistanceMeters: Double = 50

  func heatmapGradient(for points: [CLLocation], defaultColor: Color) -> Gradient {
    guard points.count > 1 else {
      return Gradient(colors: [defaultColor])
    }

    // Create an array that tracks the cumulative distance for each point
    var cumulativeDistance: [Double] = [0]
    cumulativeDistance.reserveCapacity(points.count)
    for i in 1 ..< points.count {
      let distance = points[i - 1].distance(from: points[i])
      cumulativeDistance.append(cumulativeDistance[i - 1] + distance)
    }

    let totalDistance = cumulativeDistance.last ?? 0
    guard totalDistance > 0 else {
      return Gradient(colors: [defaultColor])
    }

    // Sample the points. We don't want too many measurements
    let sampleCount = max(2, Int(ceil(totalDistance / sampleDistanceMeters)) + 1)

    var sampleIndices: [Int] = []
    sampleIndices.reserveCapacity(sampleCount)
    var target: Double = 0
    var j = 0
    for _ in 0 ..< sampleCount {
      while j < cumulativeDistance.count - 1 && cumulativeDistance[j] < target {
        j += 1
      }
      sampleIndices.append(min(j, cumulativeDistance.count - 1))
      target += sampleDistanceMeters
    }

    // Calculate the at each sample
    var speeds: [Double] = []
    speeds.reserveCapacity(max(1, sampleIndices.count - 1))
    for k in 1 ..< sampleIndices.count {
      let idx0 = sampleIndices[k - 1]
      let idx1 = sampleIndices[k]
      guard idx1 != idx0 else {
        continue
      }

      let distance = cumulativeDistance[idx1] - cumulativeDistance[idx0]
      let dt = points[idx1].timestamp.timeIntervalSince(points[idx0].timestamp)
      guard dt > 0 else {
        continue
      }

      let v = distance / dt
      speeds.append(v)
    }

    guard !speeds.isEmpty else {
      return Gradient(colors: [defaultColor])
    }

    // Normalize speeds to 0...1
    let minSpeed = speeds.min() ?? 0
    let maxSpeed = speeds.max() ?? 1
    let range = max(maxSpeed - minSpeed, 0.0001)
    let normalized = speeds.map {
      ($0 - minSpeed) / range
    }

    // Build gradient stops along the path proportionally to distance
    // Place stops at the midpoint of each sampled segment
    var stops: [Gradient.Stop] = []
    stops.reserveCapacity(normalized.count)

    for k in 0 ..< normalized.count {
      let startIdx = sampleIndices[k]
      let endIdx = sampleIndices[k + 1]
      let midDist = (cumulativeDistance[endIdx] + cumulativeDistance[startIdx]) * 0.5
      let location = totalDistance > 0 ? midDist / totalDistance : 0
      let color = colorForNormalizedSpeed(normalized[k])
      stops.append(.init(color: color, location: location))
    }

    return Gradient(stops: stops)
  }

  private func colorForNormalizedSpeed(_ t: Double) -> Color {
    let clamped = max(0, min(1, t))
    let colorIndex = Int(round(clamped * Double(Color.routeColors.count - 1)))
    return Color.routeColors[colorIndex]
  }
}
