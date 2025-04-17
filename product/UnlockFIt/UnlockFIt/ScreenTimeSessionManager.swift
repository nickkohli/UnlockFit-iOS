import Foundation
import UserNotifications
import ActivityKit
import Combine

class ScreenTimeSessionManager: ObservableObject {
    @Published var isSessionActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var sessionDuration: TimeInterval = 0 // Duration in seconds
    @Published var timeRemaining: TimeInterval = 0
    @Published var isFlashing: Bool = false

    private var timer: Timer?
    private var sessionStartDate: Date?
    private var cancellables = Set<AnyCancellable>()
    private var liveActivity: Activity<ScreenTimeActivityAttributes>?
    private var flashingTimer: Timer?

    func startSession(duration: TimeInterval) {
        sessionDuration = duration
        timeRemaining = duration
        sessionStartDate = Date()
        isSessionActive = true
        isPaused = false

        startTimer()
        scheduleNotification()
        startLiveActivity()
    }

    func stopSession() {
        timer?.invalidate()
        timer = nil
        isSessionActive = false
        stopFlashing()
        endLiveActivity()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

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

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "UnlockFit Timer"
        content.body = "Your screen time session has ended. Please return to UnlockFit."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: sessionDuration, repeats: false)
        let request = UNNotificationRequest(identifier: "ScreenTimeSessionEnded", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

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

    private func startFlashing() {
        flashingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.isFlashing.toggle()
                self.updateLiveActivity()
            }
        }
    }

    private func stopFlashing() {
        flashingTimer?.invalidate()
        flashingTimer = nil
        isFlashing = false
    }

    func pauseSession() {
        timer?.invalidate()
        isPaused = true
    }

    func resumeSession() {
        isPaused = false
        startTimer()
    }
}
