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

  private var displayReferenceYAnnotation: Bool {
    let rangeInSeconds = to.timeIntervalSince(from)
    // Hide the reference annotation when the chart data gets within the last 20% of the chart
    return chartData.contains(where: { from.timeIntervalSince($0.date) < rangeInSeconds * 0.2 })
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
          .if(displayReferenceYAnnotation) {
            $0.annotation(position: .top, alignment: .trailing) {
              Text(String(Int(referenceY)))
                .font(.caption2)
                .foregroundStyle(color)
            }
          }
      }
    }
    .chartXAxis {
      let totalSegments = 3
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
            Text(date.formattedHourOfDay)
              .if(date == ticks.first || date == ticks.last) {
                $0.frame(width: 40, alignment: .leading)
              }
              .if(date == ticks.first) {
                $0.offset(x: 20)
              }
          }
        }
      }
    }
    .chartXScale(domain: from ... to)
    .ifLet(yDomain) { view, domain in
      view.chartYScale(domain: domain)
    }
    .chartYAxis(.hidden)
    .chartLegend(.hidden)
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}
