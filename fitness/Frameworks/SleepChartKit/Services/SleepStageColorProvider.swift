import SwiftUI
#if canImport(HealthKit)
import HealthKit
#endif

public protocol SleepStageColorProvider {
    func color(for stage: SleepStage) -> Color
    
    #if canImport(HealthKit)
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
    func color(for healthKitValue: HKCategoryValueSleepAnalysis) -> Color
    #endif
}

#if canImport(HealthKit)
@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public extension SleepStageColorProvider {
    func color(for healthKitValue: HKCategoryValueSleepAnalysis) -> Color {
        guard let stage = SleepStage(healthKitValue: healthKitValue) else {
            return .gray
        }
        return color(for: stage)
    }
}
#endif

public struct DefaultSleepStageColorProvider: SleepStageColorProvider {
    public init() {}
    
    public func color(for stage: SleepStage) -> Color {
        switch stage {
        case .awake:
            return .orange
        case .asleepREM:
            return .cyan
        case .asleepCore:
            return .blue
        case .asleepDeep:
            return .indigo
        case .asleepUnspecified:
            return .purple
        case .inBed:
            return .gray
        }
    }
    
}