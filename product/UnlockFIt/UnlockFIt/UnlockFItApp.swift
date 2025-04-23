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
                // Warm up haptic engine with a subtle selection feedback
                let selectionGenerator = UISelectionFeedbackGenerator()
                selectionGenerator.selectionChanged()

                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("❌ Notification permission error: \(error.localizedDescription)")
                    } else {
                        print("🔔 Notification permission granted: \(granted)")
                    }
                }
                screenTimeManager.historyManager = screenTimeHistory
                // Delay needed to ensure UIWindow is fully available
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UnlockFitApp.resetApp(
                        screenTimeManager: screenTimeManager,
                        screenTimeHistoryManager: screenTimeHistory
                    )
                }
            }
        }
    }
    
    static func resetApp(
        screenTimeManager: ScreenTimeSessionManager,
        screenTimeHistoryManager: ScreenTimeHistoryManager
    )
    {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("❌ Failed to access main window.")
            return
        }

        let newRootView = ContentView()
        
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())
        
            .environmentObject(screenTimeManager)
            .environmentObject(screenTimeHistoryManager)

        window.rootViewController = UIHostingController(rootView: newRootView)
        window.makeKeyAndVisible()

        print("🔁 App reset to LoginView with new state.")
    }
    
    static func resetAppWithoutScreenTime() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("❌ Failed to access main window.")
            return
        }

        let newRootView = ContentView()
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())

        window.rootViewController = UIHostingController(rootView: newRootView)
        window.makeKeyAndVisible()

        print("🔁 App reset to LoginView without ScreenTime state.")
    }
}
