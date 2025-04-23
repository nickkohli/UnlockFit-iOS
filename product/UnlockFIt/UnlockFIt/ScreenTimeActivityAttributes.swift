// ScreenTimeActivityAttributes.swift: Defines the data model for the Live Activity representing a screen-time session.
import Foundation
// Import ActivityKit to enable Live Activity support on Lock Screen and Dynamic Island.
import ActivityKit

// ScreenTimeActivityAttributes describes both the fixed attributes and the dynamic content state of a screen-time activity.
struct ScreenTimeActivityAttributes: ActivityAttributes {
    // ContentState holds the live-updating state of the activity, such as remaining time and visual cues.
    public struct ContentState: Codable, Hashable {
        // The amount of time left in the current screen-time session.
        var timeRemaining: TimeInterval
        // Indicates whether the session duration has elapsed.
        var isTimeUp: Bool
        // Controls whether the activity ring should flash to alert the user when time is up.
        var isFlashingRing: Bool
    }

    // The original total length of the session, set when the activity starts.
    var sessionDuration: TimeInterval
}
