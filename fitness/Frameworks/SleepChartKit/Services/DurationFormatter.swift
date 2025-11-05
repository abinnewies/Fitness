import Foundation

public protocol DurationFormatter {
    func format(_ duration: TimeInterval) -> String
}

public struct DefaultDurationFormatter: DurationFormatter {
    public init() {}
    
    public func format(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}