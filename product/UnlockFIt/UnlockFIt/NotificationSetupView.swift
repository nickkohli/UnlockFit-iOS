import SwiftUI
import UserNotifications

struct NotificationSetupView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var goalManager: GoalManager

    @State private var notificationsEnabled = false
    @State private var deliverySet = false
    @State private var bannerSet = false
    @State private var showWelcomeFlow = false
    
    @Binding var showOnboarding: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        DispatchQueue.main.async {
                            notificationsEnabled = settings.authorizationStatus == .authorized
                        }
                    }
                }
                VStack(spacing: 30) {
                    Text("🔔 Notification Setup")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    ScrollView {
                        VStack(spacing: 30) {
                            // Step 1
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Step 1: Enable Notifications")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    if notificationsEnabled {
                                        Text("✔")
                                            .foregroundColor(.green)
                                    }
                                }
                                Text("Turn on notifications for UnlockFit to receive reminders and updates.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Image("notif_toggle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 67)
                                    .cornerRadius(10)
                                    .opacity(deliverySet ? 0.3 : (notificationsEnabled ? 1.0 : 0.3))

                                Button(action: {
                                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                                        DispatchQueue.main.async {
                                            if settings.authorizationStatus == .authorized {
                                                notificationsEnabled = true
                                            } else {
                                                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                                    UIApplication.shared.open(settingsURL)
                                                }
                                            }
                                        }
                                    }
                                }) {
                                    Text(notificationsEnabled ? "Step Complete!" : "Enable Notifications")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(notificationsEnabled ? Color.green.opacity(0.5) : Color.gray.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }

                            // Step 2
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Step 2: Set Delivery to Immediate")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    if deliverySet {
                                        Text("✔")
                                            .foregroundColor(.green)
                                    }
                                }
                                Text("Make sure notifications are delivered immediately instead of being scheduled.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Image("notif_delivery")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(10)
                                    .opacity(deliverySet ? 0.3 : (notificationsEnabled ? 1.0 : 0.3))

                                Button(action: {
                                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsURL)
                                        deliverySet = true // Simulated
                                    }
                                }) {
                                    Text(deliverySet ? "Step Complete!" : "Set to Immediate")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(deliverySet ? Color.green.opacity(0.5) : Color.gray.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled(!notificationsEnabled)
                            }

                            // Step 3
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Step 3: Make Banner Persistent")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    if bannerSet {
                                        Text("✔")
                                            .foregroundColor(.green)
                                    }
                                }
                                Text("Set notification banners to persistent so they stay until viewed.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Image("notif_banner")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(10)
                                    .opacity(bannerSet ? 0.3 : (notificationsEnabled ? 1.0 : 0.3))

                                Button(action: {
                                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsURL)
                                        bannerSet = true // Simulated
                                    }
                                }) {
                                    Text(bannerSet ? "Step Complete!" : "Set to Persistent")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(bannerSet ? Color.green.opacity(0.5) : Color.gray.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled(!notificationsEnabled)
                            }

                            Text("Once you've completed all 3 steps, continue to unlock your fitness journey.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)

                            Button(action: {
                                showWelcomeFlow = true
                            }) {
                                Text("Continue")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        Group {
                                            if notificationsEnabled && deliverySet && bannerSet {
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.purple, .pink]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            } else {
                                                Color.gray.opacity(0.3)
                                            }
                                        }
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(!(notificationsEnabled && deliverySet && bannerSet))
                            .fullScreenCover(isPresented: $showWelcomeFlow) {
                                WelcomeView(showOnboarding: $showOnboarding)
                                    .environmentObject(themeManager)
                                    .environmentObject(appState)
                                    .environmentObject(goalManager)
                            }
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        notificationsEnabled = settings.authorizationStatus == .authorized
                    }
                }
            }
        }
    }
}
