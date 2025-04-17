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
                    LiveActivityView(context: context)
                }
            } compactLeading: {
                RotatingRingView()
                    .frame(width: 20, height: 20)
            } compactTrailing: {
                TimerText(timeRemaining: context.state.timeRemaining, isTimeUp: context.state.isTimeUp)
            } minimal: {
                RotatingRingView()
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct LiveActivityView: View {
    let context: ActivityViewContext<ScreenTimeActivityAttributes>

    var body: some View {
        HStack(spacing: 8) {
            RotatingRingView()
                .frame(width: 24, height: 24)

            TimerText(timeRemaining: context.state.timeRemaining, isTimeUp: context.state.isTimeUp)
                .font(.headline)
        }
        .padding(.vertical, 6)
    }
}

struct RotatingRingView: View {
    @State private var rotation: Angle = .degrees(0)

    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.75)
            .stroke(AngularGradient(
                gradient: Gradient(colors: [.pink, .purple]),
                center: .center),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .rotationEffect(rotation)
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    rotation = .degrees(360)
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
