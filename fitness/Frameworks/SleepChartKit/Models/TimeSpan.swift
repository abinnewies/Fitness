import Foundation
import CoreGraphics

public struct TimeSpan: Hashable {
    public let time: String
    public let position: CGFloat
    
    public init(time: String, position: CGFloat) {
        self.time = time
        self.position = position
    }
}