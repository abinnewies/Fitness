import SwiftUI

/// A color provider that matches Apple's sleep chart color scheme
/// Used in Apple Health and Apple Watch sleep tracking
public struct AppleSleepColorProvider: SleepStageColorProvider {
    
    public init() {}
    
    public func color(for stage: SleepStage) -> Color {
        switch stage {
        case .awake:
            // Orange/amber for awake periods
            return Color(red: 1.0, green: 0.6, blue: 0.0)
            
        case .asleepREM:
            // Cyan/light blue for REM sleep
            return Color(red: 0.0, green: 0.7, blue: 1.0)
            
        case .asleepCore:
            // Green for light/core sleep
            return Color(red: 0.2, green: 0.8, blue: 0.4)
            
        case .asleepDeep:
            // Dark blue/indigo for deep sleep
            return Color(red: 0.2, green: 0.4, blue: 0.9)
            
        case .asleepUnspecified:
            // Purple for unspecified sleep
            return Color(red: 0.6, green: 0.4, blue: 0.9)
            
        case .inBed:
            // Light gray for time in bed
            return Color(red: 0.7, green: 0.7, blue: 0.7)
        }
    }
}

/// A color provider with muted/pastel colors for circular charts
public struct PastelSleepColorProvider: SleepStageColorProvider {
    
    public init() {}
    
    public func color(for stage: SleepStage) -> Color {
        switch stage {
        case .awake:
            return Color(red: 1.0, green: 0.8, blue: 0.6)
            
        case .asleepREM:
            return Color(red: 0.7, green: 0.9, blue: 1.0)
            
        case .asleepCore:
            return Color(red: 0.7, green: 0.95, blue: 0.8)
            
        case .asleepDeep:
            return Color(red: 0.6, green: 0.8, blue: 1.0)
            
        case .asleepUnspecified:
            return Color(red: 0.9, green: 0.8, blue: 1.0)
            
        case .inBed:
            return Color(red: 0.9, green: 0.9, blue: 0.9)
        }
    }
}

/// A high-contrast color provider for accessibility
public struct HighContrastSleepColorProvider: SleepStageColorProvider {
    
    public init() {}
    
    public func color(for stage: SleepStage) -> Color {
        switch stage {
        case .awake:
            return .red
            
        case .asleepREM:
            return .blue
            
        case .asleepCore:
            return .green
            
        case .asleepDeep:
            return .purple
            
        case .asleepUnspecified:
            return .orange
            
        case .inBed:
            return .gray
        }
    }
}