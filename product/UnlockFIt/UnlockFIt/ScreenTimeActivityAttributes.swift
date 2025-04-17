import Foundation
import ActivityKit

struct ScreenTimeActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: TimeInterval
        var isTimeUp: Bool
        var isFlashingRing: Bool
    }

    var sessionDuration: TimeInterval // The duration selected when session starts
}
