import SwiftUI

/// A SwiftUI view that displays time labels along the horizontal axis of the sleep chart.
///
/// This view shows the start and end times of the sleep session at the edges,
/// with intermediate time markers positioned according to their relative positions
/// in the timeline.
///
/// ## Features
/// - Start and end time labels at the axis edges
/// - Intermediate time markers positioned proportionally
/// - Consistent typography and styling
/// - Proper alignment with the chart above
///
/// ## Usage
/// ```swift
/// SleepTimeAxisView(
///     startTime: "10:30 PM",
///     endTime: "6:30 AM",
///     timeSpans: timeSpanMarkers
/// )
/// ```
public struct SleepTimeAxisView: View {
    
    // MARK: - Properties
    
    /// The formatted start time string for the sleep session
    private let startTime: String?
    
    /// The formatted end time string for the sleep session
    private let endTime: String?
    
    /// Array of time span markers to display along the axis
    private let timeSpans: [TimeSpan]
    
    // MARK: - Initialization
    
    /// Creates a new time axis view.
    ///
    /// - Parameters:
    ///   - startTime: The formatted start time (optional)
    ///   - endTime: The formatted end time (optional)
    ///   - timeSpans: Array of intermediate time markers (default: empty array)
    public init(startTime: String?, endTime: String?, timeSpans: [TimeSpan] = []) {
        self.startTime = startTime
        self.endTime = endTime
        self.timeSpans = timeSpans
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack {
            // Start time label
            Text(startTime ?? "")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(minWidth: SleepChartConstants.axisLabelMinWidth, alignment: .leading)
            
            Spacer()
            
            // End time label
            Text(endTime ?? "")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(minWidth: SleepChartConstants.axisLabelMinWidth, alignment: .trailing)
        }
        .overlay(alignment: .leading) {
            // Intermediate time span markers
            intermediateTimeMarkers
        }
        .padding(.horizontal, SleepChartConstants.axisHorizontalPadding)
    }
    
    // MARK: - Private Views
    
    /// Intermediate time markers positioned proportionally along the axis
    private var intermediateTimeMarkers: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - SleepChartConstants.timeSpanWidthOffset
            
            ForEach(timeSpans, id: \.time) { span in
                Text(span.time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: SleepChartConstants.timeSpanLabelWidth)
                    .position(
                        x: availableWidth * span.position + SleepChartConstants.timeSpanStartPadding,
                        y: geometry.size.height / 2
                    )
            }
        }
    }
}
