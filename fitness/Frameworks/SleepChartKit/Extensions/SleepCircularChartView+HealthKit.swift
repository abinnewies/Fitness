#if canImport(HealthKit)
import HealthKit
import SwiftUI

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public extension SleepCircularChartView {
    /// Creates a new circular sleep chart view using HealthKit samples.
    ///
    /// - Parameters:
    ///   - healthKitSamples: Array of HKCategorySample objects from HealthKit
    ///   - colorProvider: Provider for sleep stage colors (default: DefaultSleepStageColorProvider)
    ///   - lineWidth: Width of the circular segments (default: 16)
    ///   - size: Size of the circular chart (default: 160)
    ///   - backgroundColor: Background color of the chart (default: clear)
    ///   - showLabels: Whether to show time labels (default: true)
    init(
        healthKitSamples: [HKCategorySample],
        colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider(),
        lineWidth: CGFloat = 16,
        size: CGFloat = 160,
        backgroundColor: Color = .clear,
        showLabels: Bool = true
    ) {
        let sleepSamples = SleepSample.samples(from: healthKitSamples)
        self.init(
            samples: sleepSamples,
            colorProvider: colorProvider,
            lineWidth: lineWidth,
            size: size,
            backgroundColor: backgroundColor,
            showLabels: showLabels
        )
    }
}
#endif