import SwiftUI

struct NotificationSetupView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("🔔 Notification Setup")
                    .font(.title)
                    .foregroundColor(.white)

                Button(action: {
                    // Logic to return to login view, for testing
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(
                            rootView: ContentView()
                                .environmentObject(AppState())
                                .environmentObject(ThemeManager())
                                .environmentObject(GoalManager())
                                .environmentObject(ScreenTimeSessionManager())
                                .environmentObject(ScreenTimeHistoryManager())
                        )
                        window.makeKeyAndVisible()
                    }
                }) {
                    Text("Return to Login")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top, 20)
                }
            }
        }
    }
}

struct NotificationSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSetupView()
    }
}
