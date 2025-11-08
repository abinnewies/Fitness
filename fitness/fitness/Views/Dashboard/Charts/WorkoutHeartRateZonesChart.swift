//
//  WorkoutHeartRateZonesChart.swift
//  Fitness
//
//  Created by Andreas Binnewies on 11/6/25.
//

import Charts
import SwiftUI

struct WorkoutHeartRateZonesChart: View {
  private struct ZoneRow: Identifiable {
    let zone: HeartRateZone
    let seconds: TimeInterval

    var id: Int {
      zone.zoneNumber
    }

    var zoneLabel: String { "Zone \(zone.zoneNumber)" }
  }

  let from: Date
  let to: Date
  let healthKitManager: HealthKitManager

  private let rowHeight: CGFloat = 24

  @State private var chartData: [ZoneRow] = []
  @State private var showChart = false

  var body: some View {
    Chart(chartData) { row in
      BarMark(
        x: .value("Time", row.seconds),
        y: .value("Zone", row.zoneLabel),
        height: .fixed(14)
      )
      .cornerRadius(7)
      .foregroundStyle(row.zone.color)
      .annotation(position: .trailing, alignment: .center) {
        Text(row.seconds.durationFormattedShort)
          .font(.footnote.bold())
          .foregroundStyle(.secondary)
      }
    }
    .chartXAxis(.hidden)
    .chartYAxis {
      AxisMarks(preset: .extended, position: .leading) { value in
        if let label = value.as(String.self),
           let zoneNumberString = label.split(separator: " ").last,
           let zoneNumber = Int(zoneNumberString),
           let zone = HeartRateZone.zones.first(where: { $0.zoneNumber == zoneNumber })
        {
          AxisValueLabel {
            Text(label)
              .font(.footnote.bold())
              .foregroundStyle(zone.color)
          }
        } else {
          AxisValueLabel()
            .font(.footnote.bold())
        }
      }
    }
    .frame(height: CGFloat(chartData.count) * rowHeight)
    .chartLegend(.hidden)
    .opacity(showChart ? 1 : 0)
    .animation(.easeInOut(duration: 0.3), value: showChart)
    .task {
      do {
        let sampleManager = HealthKitSampleManager(healthKitManager: healthKitManager)

        let secondsPerSample: TimeInterval = 10
        let samples = try await sampleManager.fetchSamples(
          metric: .heartRate,
          from: from,
          to: to,
          stride: .timeInterval(secondsPerSample)
        )

        var durationInZone: [HeartRateZone: TimeInterval] = [:]
        for sample in samples {
          if let zone = HeartRateZone.zones.first(where: { $0.containsHeartRate(sample.value) }) {
            durationInZone[zone, default: 0] += secondsPerSample
          }
        }

        withAnimation {
          self.chartData = HeartRateZone.zones.compactMap { zone in
            let durationInZone = durationInZone[zone, default: 0]
            return durationInZone > 0 ? ZoneRow(zone: zone, seconds: durationInZone) : nil
          }
          showChart = true
        }
      } catch {}
    }
  }
}
