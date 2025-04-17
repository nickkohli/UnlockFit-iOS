import SwiftUI
import ActivityKit
import WidgetKit

struct ScreenTimeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScreenTimeActivityAttributes.self) { context in
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
                    ZStack {
                        RotatingRingView(progress: progress)
                            .frame(width: 20, height: 20)
                            .padding(4)
                    }
                }
            } compactLeading: {
                let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
                ZStack {
                    RotatingRingView(progress: progress)
                        .frame(width: 20, height: 20)
                        .padding(4)
                }
            } compactTrailing: {
                TimerText(timeRemaining: context.state.timeRemaining, isTimeUp: context.state.isTimeUp)
            } minimal: {
                let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
                ZStack {
                    RotatingRingView(progress: progress)
                        .frame(width: 20, height: 20)
                        .padding(4)
                }
            }
        }
    }
}

struct LiveActivityView: View {
    let context: ActivityViewContext<ScreenTimeActivityAttributes>

    var body: some View {
        HStack(spacing: 8) {
            let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
            RotatingRingView(progress: progress)

            TimerText(timeRemaining: context.state.timeRemaining, isTimeUp: context.state.isTimeUp)
                .font(.headline)
        }
        .padding(.vertical, 6)
    }
}

struct RotatingRingView: View {
    var progress: Double // from 1.0 (full circle) to 0.0 (empty)

    var body: some View {
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
            .rotationEffect(.degrees(270)) // Start from top
            .animation(.linear(duration: 0.2), value: progress)
    }
}

struct TimerText: View {
    let timeRemaining: TimeInterval
    let isTimeUp: Bool

    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        Text(isTimeUp ? "0:00" : formattedTime)
            .foregroundColor(isTimeUp ? .red : .white)
    }
}
