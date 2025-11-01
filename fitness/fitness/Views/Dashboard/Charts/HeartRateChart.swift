//
//  HeartRateChart.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/29/25.
//

import Charts
import SwiftUI

struct HeartRateChart: View {
  enum DateStyle {
    case hour
    case minute
  }

  let from: Date
  let to: Date
  let chartData: [HeartRateChartDataPoint]
  let color: Color
  let dateStyle: DateStyle
  let referenceY: Double?
  let displayMinMaxValues: Bool

  private static let hourLabelFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "ha"
    df.amSymbol = "a"
    df.pmSymbol = "p"
    return df
  }()

  private static let hourMinuteLabelFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "h:mm"
    return df
  }()

  private var minPoint: (x: Date, y: Double)? {
    chartData.compactMap { item in
      if let minHeartRate = item.minHeartRate { return (item.date, minHeartRate) }
      if let maxHeartRate = item.maxHeartRate { return (item.date, maxHeartRate) }
      return nil
    }.min(by: { $0.y < $1.y })
  }

  private var maxPoint: (x: Date, y: Double)? {
    chartData.compactMap { item in
      if let maxHeartRate = item.maxHeartRate { return (item.date, maxHeartRate) }
      if let minHeartRate = item.minHeartRate { return (item.date, minHeartRate) }
      return nil
    }.max(by: { $0.y < $1.y })
  }

  private var xDomain: ClosedRange<Date> {
    let sidePadding = to.timeIntervalSince(from) * 0.1
    return from.addingTimeInterval(-sidePadding) ... to.addingTimeInterval(sidePadding)
  }

  private var yDomain: ClosedRange<Double>? {
    let values: [Double] = chartData.flatMap { item in
      [item.minHeartRate, item.maxHeartRate].compactMap { $0 }
    }
    guard let minValue = values.min(), let maxValue = values.max() else {
      return nil
    }

    let verticalPadding = displayMinMaxValues ? 0.4 : 0

    if minValue == maxValue {
      let padding = max(1.0, abs(minValue) * verticalPadding)
      return (minValue - padding) ... (maxValue + padding)
    }

    let range = maxValue - minValue
    let padding = range * verticalPadding
    return (minValue - padding) ... (maxValue + padding)
  }

  var body: some View {
    Chart {
      ForEach(chartData, id: \.date) { item in
        BarMark(
          x: .value("Index", item.date),
          yStart: .value("Min", item.minHeartRate ?? 0),
          yEnd: .value("Max", item.maxHeartRate ?? 0),
          width: 3
        )
        .foregroundStyle(color)
      }

      if let minPoint, displayMinMaxValues {
        PointMark(
          x: .value("Index", minPoint.x),
          y: .value("Value", minPoint.y)
        )
        .symbolSize(0)
        .foregroundStyle(color.opacity(0.9))
        .annotation(position: .bottom, alignment: .center) {
          Text(String(Int(minPoint.y)))
            .font(.caption2)
            .foregroundStyle(color)
        }
      }

      if let maxPoint, displayMinMaxValues {
        PointMark(
          x: .value("Index", maxPoint.x),
          y: .value("Value", maxPoint.y)
        )
        .symbolSize(0)
        .foregroundStyle(color.opacity(0.9))
        .annotation(position: .top, alignment: .center) {
          Text(String(Int(maxPoint.y)))
            .font(.caption2)
            .foregroundStyle(color)
        }
      }

      if let referenceY {
        RuleMark(y: .value("Reference", referenceY))
          .foregroundStyle(color)
          .lineStyle(StrokeStyle(lineWidth: 1, dash: [2, 2]))
          .annotation(position: .top, alignment: .trailing) {
            Text(String(Int(referenceY)))
              .font(.caption2)
              .foregroundStyle(color)
          }
      }
    }
    .chartXAxis {
      let totalSegments = 4
      let start = from.timeIntervalSinceReferenceDate
      let end = to.timeIntervalSinceReferenceDate
      let step = (end - start) / Double(totalSegments)
      let ticks: [Date] = (0 ... totalSegments).map { i in
        Date(timeIntervalSinceReferenceDate: start + Double(i) * step)
      }

      AxisMarks(preset: .aligned, values: ticks) { value in
        AxisGridLine()
        AxisTick()
        AxisValueLabel {
          if let date = value.as(Date.self) {
            if dateStyle == .hour {
              Text(Self.hourLabelFormatter.string(from: date))
            } else {
              Text(Self.hourMinuteLabelFormatter.string(from: date))
            }
          }
        }
      }
    }
    .chartXScale(domain: xDomain)
    .ifLet(yDomain) { view, domain in
      view.chartYScale(domain: domain)
    }
    .chartYAxis(.hidden)
    .chartLegend(.hidden)
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}
