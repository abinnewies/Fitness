import Foundation

public protocol SleepStageDisplayNameProvider {
    func displayName(for stage: SleepStage) -> String
}

public struct DefaultSleepStageDisplayNameProvider: SleepStageDisplayNameProvider {
    public init() {}
    
    public func displayName(for stage: SleepStage) -> String {
        stage.defaultDisplayName
    }
}

public struct CustomSleepStageDisplayNameProvider: SleepStageDisplayNameProvider {
    private let customNames: [SleepStage: String]
    
    public init(customNames: [SleepStage: String]) {
        self.customNames = customNames
    }
    
    public func displayName(for stage: SleepStage) -> String {
        customNames[stage] ?? stage.defaultDisplayName
    }
}

public struct LocalizedSleepStageDisplayNameProvider: SleepStageDisplayNameProvider {
    private let bundle: Bundle
    private let tableName: String?
    
    public init(bundle: Bundle = .main, tableName: String? = nil) {
        self.bundle = bundle
        self.tableName = tableName
    }
    
    public func displayName(for stage: SleepStage) -> String {
        let key = "sleep_stage_\(stage)"
        let localizedString = NSLocalizedString(key, tableName: tableName, bundle: bundle, comment: "")
        return localizedString != key ? localizedString : stage.defaultDisplayName
    }
}