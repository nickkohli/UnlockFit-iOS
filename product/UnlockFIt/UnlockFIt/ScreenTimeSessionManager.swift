import Foundation
import UserNotifications
import ActivityKit
import Combine

class ScreenTimeSessionManager: ObservableObject {
    @Published var isSessionActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var sessionDuration: TimeInterval = 0 // Duration in seconds
    @Published var timeRemaining: TimeInterval = 0

    private var timer: Timer?
    private var sessionStartDate: Date?
    private var cancellables = Set<AnyCancellable>()

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
        endLiveActivity()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                self.timeRemaining = 0
                self.isPaused = false
                // The session remains active, user must manually stop it
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
        // Placeholder: Implement ActivityKit integration
    }

    private func endLiveActivity() {
        // Placeholder: End ActivityKit session
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
