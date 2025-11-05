#if canImport(HealthKit)
import SwiftUI
import HealthKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public struct HealthKitExampleView: View {
    @State private var sleepSamples: [HKCategorySample] = []
    
    public var body: some View {
        VStack {
            if !sleepSamples.isEmpty {
                // Example 1: Using HealthKit samples directly
                SleepChartView(healthKitSamples: sleepSamples)
                    .padding()
                
                // Example 2: Using HealthKit samples with custom display names
                SleepChartView(
                    healthKitSamples: sleepSamples,
                    displayNameProvider: CustomSleepStageDisplayNameProvider(customNames: [
                        .awake: "Awake",
                        .asleepREM: "REM Sleep",
                        .asleepCore: "Light Sleep",
                        .asleepDeep: "Deep Sleep",
                        .asleepUnspecified: "Unknown Sleep",
                        .inBed: "In Bed"
                    ])
                )
                .padding()
                
                // Example 3: Using localized display names
                SleepChartView(
                    healthKitSamples: sleepSamples,
                    displayNameProvider: LocalizedSleepStageDisplayNameProvider()
                )
                .padding()
            } else {
                Text("No sleep data available")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        // Example of creating sample HealthKit data for demonstration
        // In a real app, you would fetch this from HealthKit
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        
        // Create sample sleep data
        sleepSamples = [
            createSample(stage: .inBed, start: yesterday.addingTimeInterval(22 * 3600), duration: 8 * 3600),
            createSample(stage: .awake, start: yesterday.addingTimeInterval(22 * 3600), duration: 0.5 * 3600),
            createSample(stage: .asleepCore, start: yesterday.addingTimeInterval(22.5 * 3600), duration: 1.5 * 3600),
            createSample(stage: .asleepDeep, start: yesterday.addingTimeInterval(24 * 3600), duration: 2 * 3600),
            createSample(stage: .asleepREM, start: yesterday.addingTimeInterval(26 * 3600), duration: 1 * 3600),
            createSample(stage: .asleepCore, start: yesterday.addingTimeInterval(27 * 3600), duration: 1.5 * 3600),
            createSample(stage: .awake, start: yesterday.addingTimeInterval(28.5 * 3600), duration: 0.5 * 3600),
            createSample(stage: .asleepREM, start: yesterday.addingTimeInterval(29 * 3600), duration: 1 * 3600)
        ]
    }
    
    private func createSample(stage: HKCategoryValueSleepAnalysis, start: Date, duration: TimeInterval) -> HKCategorySample {
        let sleepType = HKCategoryType(.sleepAnalysis)
        let endDate = start.addingTimeInterval(duration)
        
        return HKCategorySample(
            type: sleepType,
            value: stage.rawValue,
            start: start,
            end: endDate
        )
    }
}

// MARK: - Usage Examples

public struct UsageExamples {
    
    /// Example: Converting HealthKit samples to SleepSample
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
    public static func convertHealthKitSamples(_ healthKitSamples: [HKCategorySample]) -> [SleepSample] {
        return SleepSample.samples(from: healthKitSamples)
    }
    
    /// Example: Custom color provider for HealthKit
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
    public static func customColorProvider() -> SleepStageColorProvider {
        return DefaultSleepStageColorProvider()
    }
    
    /// Example: Custom localization
    public static func localizedDisplayNames() -> SleepStageDisplayNameProvider {
        return LocalizedSleepStageDisplayNameProvider(bundle: .main, tableName: "SleepStages")
    }
    
    /// Example: Custom display names
    public static func customDisplayNames() -> SleepStageDisplayNameProvider {
        return CustomSleepStageDisplayNameProvider(customNames: [
            .awake: "Vigile",
            .asleepREM: "Sommeil REM",
            .asleepCore: "Sommeil Léger",
            .asleepDeep: "Sommeil Profond",
            .asleepUnspecified: "Sommeil",
            .inBed: "Au Lit"
        ])
    }
}
#endif