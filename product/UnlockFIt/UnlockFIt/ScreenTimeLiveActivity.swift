// ScreenTimeLiveActivity.swift: Defines the Live Activity widget for ongoing screen-time sessions on Lock Screen and Dynamic Island.
import SwiftUI
// Import ActivityKit for Live Activity support.
import ActivityKit
// Import WidgetKit to register the widget configuration.
import WidgetKit

// ScreenTimeLiveActivity configures the Live Activity UI for both Dynamic Island and Lock Screen.
struct ScreenTimeLiveActivity: Widget {
    // Define the ActivityConfiguration using our custom ScreenTimeActivityAttributes.
    var body: some WidgetConfiguration {
        // Provide the Lock Screen / banner view for the live activity.
        ActivityConfiguration(for: ScreenTimeActivityAttributes.self) { context in
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            // Define the Dynamic Island presentation for expanded, compact, and minimal regions.
            DynamicIsland {
                // Expanded Dynamic Island content.
                DynamicIslandExpandedRegion(.leading) {
                    let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
                    ZStack {
                        RotatingRingView(progress: progress, flashing: context.state.isFlashingRing)
                            .frame(width: 20, height: 20)
                            .padding(4)
                    }
                }
            } 
            // Compact leading region for Dynamic Island.
            compactLeading: {
                let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
                ZStack {
                    RotatingRingView(progress: progress, flashing: context.state.isFlashingRing)
                        .frame(width: 20, height: 20)
                        .padding(4)
                }
            } 
            // Compact trailing region showing the timer text.
            compactTrailing: {
                TimerText(timeRemaining: context.state.timeRemaining, isTimeUp: context.state.isTimeUp)
            } 
            // Minimal region showing only the progress ring.
            minimal: {
                let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
                ZStack {
                    RotatingRingView(progress: progress, flashing: context.state.isFlashingRing)
                        .frame(width: 20, height: 20)
                        .padding(4)
                }
            }
        }
    }
}

// LiveActivityView displays the ring and timer for Lock Screen and banner.
struct LiveActivityView: View {
    // Context provides the current activity state and attributes.
    let context: ActivityViewContext<ScreenTimeActivityAttributes>

    // Layout the progress ring and timer in a horizontal stack.
    var body: some View {
        HStack(spacing: 8) {
            let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
            RotatingRingView(progress: progress, flashing: context.state.isFlashingRing)

            TimerText(timeRemaining: context.state.timeRemaining, isTimeUp: context.state.isTimeUp)
                .font(.headline)
        }
        .padding(.vertical, 6)
    }
}

// RotatingRingView draws a circular progress indicator and handles flashing when time is up.
struct RotatingRingView: View {
    // Progress from 0.0 to 1.0 indicating fraction of session duration remaining.
    var progress: Double
    // Controls whether the ring should flash to alert the user.
    var flashing: Bool = false
    // Internal state for flashing ring opacity animation.
    @State private var ringOpacity: Double = 1.0

    // Render either the trimmed progress ring or a flashing full ring when time is up.
    var body: some View {
        ZStack {
            if progress > 0 {
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.pink, .purple]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(270))
                    .animation(.linear(duration: 0.2), value: progress)
            } else {
                Circle()
                    .stroke(Color.red.opacity(ringOpacity), lineWidth: 4)
                    .frame(width: 20, height: 20)
                    .onAppear {
                        if flashing {
                            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                ringOpacity = 0.2
                            }
                        }
                    }
            }
        }
    }
}

// TimerText formats and displays the remaining time, turning red when time is up.
struct TimerText: View {
    // The amount of time left in the session.
    let timeRemaining: TimeInterval
    // Indicates if the session has ended.
    let isTimeUp: Bool

    // Compute a mm:ss string from the timeRemaining value.
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // Display the formatted time with conditional coloring.
    var body: some View {
        Text(isTimeUp ? "0:00" : formattedTime)
            .foregroundColor(isTimeUp ? .red : .white)
    }
}
