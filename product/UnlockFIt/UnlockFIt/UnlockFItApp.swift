import SwiftUI
import UIKit
import UserNotifications
import Firebase

@main
struct UnlockFitApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var appState = AppState()
    @StateObject private var goalManager = GoalManager()
    @StateObject private var screenTimeManager = ScreenTimeSessionManager()
    @StateObject private var screenTimeHistory = ScreenTimeHistoryManager()

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("✅ Firebase configured")
        } else {
            print("⚠️ Firebase already configured")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                ContentView()
                    .environmentObject(themeManager)
                    .environmentObject(appState)
                    .environmentObject(goalManager)
                    .environmentObject(screenTimeManager)
                    .environmentObject(screenTimeHistory)
            }
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("❌ Notification permission error: \(error.localizedDescription)")
                    } else {
                        print("🔔 Notification permission granted: \(granted)")
                    }
                }
                screenTimeManager.historyManager = screenTimeHistory
            }
        }
    }
}
