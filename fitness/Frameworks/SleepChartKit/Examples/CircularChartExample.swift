import SwiftUI
#if canImport(HealthKit)
import HealthKit
#endif

/// Example demonstrating how to use the circular sleep chart
public struct CircularChartExample: View {
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Basic circular chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Basic Circular Chart")
                        .font(.headline)
                    
                    SleepChartView(
                        samples: sampleSleepData,
                        style: .circular
                    )
                }
                
                // Large circular chart with custom styling
                VStack(alignment: .leading, spacing: 16) {
                    Text("Large Circular Chart")
                        .font(.headline)
                    
                    SleepChartView(
                        samples: sampleSleepData,
                        style: .circular,
                        circularConfig: CircularChartConfiguration(
                            lineWidth: 24,
                            size: 200,
                            showLabels: true
                        )
                    )
                }
                
                // Compact circular chart without labels
                VStack(alignment: .leading, spacing: 16) {
                    Text("Compact Chart (No Labels)")
                        .font(.headline)
                    
                    SleepCircularChartView(
                        samples: sampleSleepData,
                        lineWidth: 12,
                        size: 120,
                        showLabels: false
                    )
                }
                
                // Apple-style colors with sun/moon symbols
                VStack(alignment: .leading, spacing: 16) {
                    Text("Apple Health Style")
                        .font(.headline)
                    
                    Text("Shows 24-hour circle with sun/moon symbols and gray areas for awake time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SleepChartView(
                        samples: sampleSleepData,
                        style: .circular,
                        circularConfig: CircularChartConfiguration(
                            lineWidth: 18,
                            size: 200,
                            showLabels: true
                        ),
                        colorProvider: AppleSleepColorProvider()
                    )
                }
                
                // Custom colors
                VStack(alignment: .leading, spacing: 16) {
                    Text("Custom Colors")
                        .font(.headline)
                    
                    SleepChartView(
                        samples: sampleSleepData,
                        style: .circular,
                        circularConfig: CircularChartConfiguration(size: 180),
                        colorProvider: CustomColorProvider()
                    )
                }
                
                #if canImport(HealthKit)
                if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
                    // HealthKit integration example
                    VStack(alignment: .leading, spacing: 16) {
                        Text("HealthKit Integration")
                            .font(.headline)
                        
                        Text("Use with HealthKit data:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SleepChartView(")
                            Text("  healthKitSamples: samples,")
                            Text("  style: .circular,")
                            Text("  circularConfig: CircularChartConfiguration(size: 200)")
                            Text(")")
                        }
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                #endif
            }
            .padding()
        }
        .navigationTitle("Circular Sleep Charts")
    }
    
    // MARK: - Sample Data
    
    private var sampleSleepData: [SleepSample] {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        
        // Sleep session from 10:30 PM to 7:15 AM (representing a typical night)
        let bedTime = calendar.date(byAdding: .hour, value: 22, to: baseDate)!
            .addingTimeInterval(30 * 60) // 10:30 PM
        
        return [
            // Time in bed before falling asleep
            SleepSample(
                stage: .inBed,
                startDate: bedTime,
                endDate: bedTime.addingTimeInterval(20 * 60) // 20 minutes to fall asleep
            ),
            // Light sleep phase
            SleepSample(
                stage: .asleepCore,
                startDate: bedTime.addingTimeInterval(20 * 60),
                endDate: bedTime.addingTimeInterval(2 * 3600) // 2 hours of light sleep
            ),
            // Deep sleep phase
            SleepSample(
                stage: .asleepDeep,
                startDate: bedTime.addingTimeInterval(2 * 3600),
                endDate: bedTime.addingTimeInterval(4.5 * 3600) // 2.5 hours of deep sleep
            ),
            // REM sleep phase
            SleepSample(
                stage: .asleepREM,
                startDate: bedTime.addingTimeInterval(4.5 * 3600),
                endDate: bedTime.addingTimeInterval(7 * 3600) // 2.5 hours of REM
            ),
            // Brief awakening
            SleepSample(
                stage: .awake,
                startDate: bedTime.addingTimeInterval(7 * 3600),
                endDate: bedTime.addingTimeInterval(7.25 * 3600) // 15 minute awakening
            ),
            // Final light sleep
            SleepSample(
                stage: .asleepCore,
                startDate: bedTime.addingTimeInterval(7.25 * 3600),
                endDate: bedTime.addingTimeInterval(8.75 * 3600) // Until 7:15 AM
            )
        ]
    }
}

// MARK: - Custom Color Provider

private struct CustomColorProvider: SleepStageColorProvider {
    func color(for stage: SleepStage) -> Color {
        switch stage {
        case .awake:
            return .red
        case .asleepREM:
            return .purple
        case .asleepCore:
            return .green
        case .asleepDeep:
            return .blue
        case .asleepUnspecified:
            return .gray
        case .inBed:
            return .yellow
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CircularChartExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CircularChartExample()
        }
    }
}
#endif
