import SwiftUI
import ConfettiSwiftUI

struct WelcomeView: View {
    @State private var confettiCounter = 0
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var goalManager: GoalManager
    @EnvironmentObject var screenTimeManager: ScreenTimeSessionManager
    @EnvironmentObject var screenTimeHistory: ScreenTimeHistoryManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()
                VStack(spacing: 10) {
                    Text("🎉 Welcome to UnlockFit!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)

                    Text("You're all set to start your fitness journey.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)

                    Button(action: {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            // Create a brand new instance of UnlockFitApp's ContentView with fresh state objects
                            let newRootView = ContentView()
                                .environmentObject(ThemeManager())
                                .environmentObject(AppState())
                                .environmentObject(GoalManager())
                                .environmentObject(ScreenTimeSessionManager())
                                .environmentObject(ScreenTimeHistoryManager())

                            window.rootViewController = UIHostingController(rootView: newRootView)
                            window.makeKeyAndVisible()
                        }
                    }) {
                        Text("Continue to Login")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [.purple, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .confettiCannon(trigger: $confettiCounter, repetitions: 3, repetitionInterval: 0.5)
            .onAppear {
                confettiCounter += 1
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())
            .environmentObject(ScreenTimeSessionManager())
            .environmentObject(ScreenTimeHistoryManager())
    }
}
