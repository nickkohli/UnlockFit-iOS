// UnlockFitApp.swift: The app’s entry point; sets up Firebase, state objects, and root view.
import SwiftUI
// Import UIKit for UIHostingController and application lifecycle control.
import UIKit
// Import UserNotifications to request notification permissions and schedule alerts.
import UserNotifications
// Import Firebase core to configure the Firebase app.
import Firebase

// The main App struct launching the SwiftUI application.
@main
struct UnlockFitApp: App {
    // StateObjects for global managers: theme, authentication state, fitness goals, screen-time sessions/history.
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var appState = AppState()
    @StateObject private var goalManager = GoalManager()
    @StateObject private var screenTimeManager = ScreenTimeSessionManager()
    @StateObject private var screenTimeHistory = ScreenTimeHistoryManager()

    // App initialiser: configure Firebase if needed and log the result.
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("✅ Firebase configured")
        } else {
            print("⚠️ Firebase already configured")
        }
    }

    // Define the main window group and attach environment objects to ContentView.
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
            // On appear of the root view: warm up haptics, request notification authorisation, and set up session history link.
            .onAppear {
                // Warm up the haptic engine with a subtle selection feedback.
                let selectionGenerator = UISelectionFeedbackGenerator()
                selectionGenerator.selectionChanged()

                // Prompt the user for notification permissions (alert, sound, badge).
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("❌ Notification permission error: \(error.localizedDescription)")
                    } else {
                        print("🔔 Notification permission granted: \(granted)")
                    }
                }
                // Assign the shared history manager to the session manager for logging sessions.
                screenTimeManager.historyManager = screenTimeHistory
                // After a brief delay, reset the app’s root view to ensure onboarding state is applied.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UnlockFitApp.resetApp(
                        screenTimeManager: screenTimeManager,
                        screenTimeHistoryManager: screenTimeHistory
                    )
                }
            }
        }
    }
    
    // Reset the app’s root view controller with full state including screen-time managers.
    static func resetApp(
        screenTimeManager: ScreenTimeSessionManager,
        screenTimeHistoryManager: ScreenTimeHistoryManager
    )
    {
        // Safely access the main UIWindow to replace its rootViewController.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("❌ Failed to access main window.")
            return
        }

        // Build a new ContentView with fresh environment objects for a clean login or main UI.
        let newRootView = ContentView()
        
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())
        
            .environmentObject(screenTimeManager)
            .environmentObject(screenTimeHistoryManager)

        // Apply the new rootViewController to restart the UI flow.
        window.rootViewController = UIHostingController(rootView: newRootView)
        window.makeKeyAndVisible()

        // Log that the app has been reset with full state.
        print("🔁 App reset to LoginView with new state.")
    }
    
    // Reset the app’s root view without restoring screen-time session state.
    static func resetAppWithoutScreenTime() {
        // Ensure we have a valid window before modifying the rootViewController.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("❌ Failed to access main window.")
            return
        }

        // Create ContentView with only theme, auth, and goal managers (no screen-time).
        let newRootView = ContentView()
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())

        // Apply the new rootViewController to restart the UI flow.
        window.rootViewController = UIHostingController(rootView: newRootView)
        window.makeKeyAndVisible()

        // Log that the app has been reset without screen-time state.
        print("🔁 App reset to LoginView without ScreenTime state.")
    }
}
