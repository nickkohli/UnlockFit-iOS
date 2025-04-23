import Foundation
import UserNotifications
import ActivityKit
import Combine

// ScreenTimeSessionManager manages the lifecycle of a screen-time session: timing, notifications, history, and Live Activity updates.
class ScreenTimeSessionManager: ObservableObject {
    // Published state for session activity, pause status, timing values, flashing alert, and history synchronization.
    @Published var isSessionActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var sessionDuration: TimeInterval = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var isFlashing: Bool = false
    @Published var historyManager: ScreenTimeHistoryManager?

    // Timer for counting down the session second-by-second.
    private var timer: Timer?
    // Records when the session began to compute actual duration.
    private var sessionStartDate: Date?
    private var cancellables = Set<AnyCancellable>()
    private var liveActivity: Activity<ScreenTimeActivityAttributes>?
    private var flashingTimer: Timer?
    private var pauseStartDate: Date?
    // Accumulates time spent paused so it is excluded from session duration.
    private var totalPausedTime: TimeInterval = 0

    // Start a new screen-time session: reset state, start countdown, schedule notification, and launch Live Activity.
    func startSession(duration: TimeInterval) {
        sessionDuration = duration
        timeRemaining = duration
        sessionStartDate = Date()
        isSessionActive = true
        isPaused = false
        totalPausedTime = 0
        pauseStartDate = nil

        startTimer()
        if isPaused {
            pauseSession()
        }
        scheduleNotification()
        startLiveActivity()
    }

    // Stop the session: finalize timing, log to history, end Live Activity, and clear pending notifications.
    func stopSession() {
        timer?.invalidate()
        timer = nil
        isSessionActive = false
        
        if let startDate = sessionStartDate {
            let actualDuration = Date().timeIntervalSince(startDate) - totalPausedTime
            print("🕒 sessionStartDate: \(String(describing: sessionStartDate))")
            print("📈 Logging session duration: \(actualDuration) seconds")
            historyManager?.addSession(duration: actualDuration)
        }
        
        stopFlashing()
        endLiveActivity()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // Internal: decrement timeRemaining every second and trigger flashing when time runs out.
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timeRemaining -= 1
            self.updateLiveActivity()
            if self.timeRemaining <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                self.timeRemaining = 0
                self.isPaused = false
                self.startFlashing()
            }
        }
    }

    // Internal: schedule a time-sensitive local notification for session end.
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "UnlockFit Timer"
        content.body = "⏳ Your screen time session ended, but we’re still counting! Return to UnlockFit to log it properly."
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: sessionDuration, repeats: false)
        let request = UNNotificationRequest(identifier: "ScreenTimeSessionEnded", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // Internal: begin a Live Activity on Lock Screen / Dynamic Island to show session progress.
    private func startLiveActivity() {
        let attributes = ScreenTimeActivityAttributes(sessionDuration: sessionDuration)
        let initialState = ScreenTimeActivityAttributes.ContentState(
            timeRemaining: timeRemaining,
            isTimeUp: false,
            isFlashingRing: false
        )

        do {
            liveActivity = try Activity<ScreenTimeActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            print("📡 Live Activity successfully started!")
        } catch {
            print("❌ Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    // Internal: end the Live Activity with time-up state and flashing ring.
    private func endLiveActivity() {
        Task {
            let finalContent = ScreenTimeActivityAttributes.ContentState(timeRemaining: 0, isTimeUp: true, isFlashingRing: true)
            await liveActivity?.end(
                ActivityContent(state: finalContent, staleDate: nil),
                dismissalPolicy: .immediate
            )
            liveActivity = nil
        }
    }
    
    // Internal: push updated timeRemaining and flashing state to the Live Activity.
    private func updateLiveActivity() {
        Task {
            let updatedContent = ScreenTimeActivityAttributes.ContentState(
                timeRemaining: timeRemaining,
                isTimeUp: timeRemaining <= 0,
                isFlashingRing: isFlashing
            )
            await liveActivity?.update(ActivityContent(state: updatedContent, staleDate: nil))
        }
    }

    // Internal: start a timer to toggle flashing state for the Live Activity ring.
    private func startFlashing() {
        flashingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.isFlashing.toggle()
                self.updateLiveActivity()
            }
        }
    }

    // Internal: stop the flashing timer and reset flashing state.
    private func stopFlashing() {
        flashingTimer?.invalidate()
        flashingTimer = nil
        isFlashing = false
    }

    // Pause the countdown timer and record the pause start time.
    func pauseSession() {
        timer?.invalidate()
        isPaused = true
        pauseStartDate = Date()
    }

    // Resume a paused session: adjust totalPausedTime and restart the countdown timer.
    func resumeSession() {
        if isPaused {
            isPaused = false
            if let pauseStart = pauseStartDate {
                totalPausedTime += Date().timeIntervalSince(pauseStart)
                pauseStartDate = nil
            }
            startTimer()
        }
    }
}
