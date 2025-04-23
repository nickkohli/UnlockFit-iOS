import SwiftUI
import ActivityKit
import WidgetKit

struct ScreenTimeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScreenTimeActivityAttributes.self) { context in
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
                    ZStack {
                        RotatingRingView(progress: progress, flashing: context.state.isFlashingRing)
                            .frame(width: 20, height: 20)
                            .padding(4)
                    }
                }
            } compactLeading: {
                let progress = max(min(context.state.timeRemaining / context.attributes.sessionDuration, 1.0), 0.0)
                ZStack {
                    RotatingRingView(progress: progress, flashing: context.state.isFlashingRing)
                        .frame(width: 20, height: 20)
                        .padding(4)
                }
            } compactTrailing: {
                TimerText(timeRemaining: context.state.timeRemaining, isTimeUp: context.state.isTimeUp)
            } minimal: {
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

struct LiveActivityView: View {
    let context: ActivityViewContext<ScreenTimeActivityAttributes>

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

struct RotatingRingView: View {
    var progress: Double
    var flashing: Bool = false
    @State private var ringOpacity: Double = 1.0

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
