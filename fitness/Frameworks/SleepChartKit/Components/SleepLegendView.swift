import SwiftUI

public struct SleepLegendView: View {
    private let activeStages: [SleepStage]
    private let sleepData: [SleepStage: TimeInterval]
    private let colorProvider: SleepStageColorProvider
    private let durationFormatter: DurationFormatter
    private let displayNameProvider: SleepStageDisplayNameProvider
    
    public init(
        activeStages: [SleepStage],
        sleepData: [SleepStage: TimeInterval],
        colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider(),
        durationFormatter: DurationFormatter = DefaultDurationFormatter(),
        displayNameProvider: SleepStageDisplayNameProvider = DefaultSleepStageDisplayNameProvider()
    ) {
        self.activeStages = activeStages
        self.sleepData = sleepData
        self.colorProvider = colorProvider
        self.durationFormatter = durationFormatter
        self.displayNameProvider = displayNameProvider
    }
    
    // MARK: - Layout Configuration
    
    /// Grid configuration for legend items with adaptive sizing
    private var columns: [GridItem] {
        [GridItem(.adaptive(
            minimum: SleepChartConstants.legendItemMinWidth,
            maximum: SleepChartConstants.legendItemMaxWidth
        ))]
    }
    
    // MARK: - Body
    
    public var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: SleepChartConstants.legendItemSpacing
        ) {
            ForEach(activeStages, id: \.self) { stage in
                // Only show stages that have recorded time
                if let duration = sleepData[stage], duration > 0 {
                    LegendItem(
                        stage: stage,
                        duration: duration,
                        colorProvider: colorProvider,
                        durationFormatter: durationFormatter,
                        displayNameProvider: displayNameProvider
                    )
                }
            }
        }
    }
}

/// A single legend item displaying a sleep stage with its color, name, and duration.
///
/// This view shows a colored circle indicator, the stage name, and formatted duration
/// in a horizontal layout suitable for use in a legend grid.
private struct LegendItem: View {
    
    // MARK: - Properties
    
    /// The sleep stage this item represents
    let stage: SleepStage
    
    /// The total duration for this sleep stage
    let duration: TimeInterval
    
    /// Provider for the stage color
    let colorProvider: SleepStageColorProvider
    
    /// Formatter for the duration display
    let durationFormatter: DurationFormatter
    
    /// Provider for the stage display name
    let displayNameProvider: SleepStageDisplayNameProvider
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: SleepChartConstants.legendItemSpacing) {
            // Color indicator circle
            Circle()
                .fill(colorProvider.color(for: stage))
                .frame(
                    width: SleepChartConstants.legendCircleSize,
                    height: SleepChartConstants.legendCircleSize
                )
            
            // Stage name
            Text(displayNameProvider.displayName(for: stage))
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Duration
            Text(durationFormatter.format(duration))
                .font(.caption.weight(.semibold))
                .foregroundColor(.primary)
        }
    }
}