// WelcomeView.swift: Onboarding screen showing a welcome message, confetti animation, and navigation to login.
import SwiftUI
import ConfettiSwiftUI
import UIKit

// WelcomeView displays a celebratory welcome with confetti and a Continue button to proceed.
struct WelcomeView: View {
    // Controls how many times the confetti animation is triggered.
    @State private var confettiCounter = 0
    // Environment objects for theme, authentication state, and goal management.
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var goalManager: GoalManager
    
    // Binding to control whether the onboarding screens are shown.
    @Binding var showOnboarding: Bool

    // The view body builds the ZStack background, welcome text, button, and confetti behavior.
    var body: some View {
        // ZStack to layer a black background with the content and confetti effect.
        ZStack {
            // Full-screen black background.
            Color.black.ignoresSafeArea()

            // Centered vertical stack for welcome texts and Continue button.
            VStack {
                Spacer()
                // Main welcome title with emoji.
                VStack(spacing: 10) {
                    // Main welcome title with emoji.
                    Text("Welcome to UnlockFit! 🎉")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)

                    // Subtitle encouraging the user to begin.
                    Text("You're all set to start your fitness journey.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)

                    // Continue button: triggers haptic feedback and dismisses onboarding.
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        showOnboarding = false
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
            // Attach confetti animation that fires when confettiCounter changes.
            .confettiCannon(trigger: $confettiCounter, repetitions: 3, repetitionInterval: 0.5)
            // On appear: trigger confetti and play a success haptic.
            .onAppear {
                confettiCounter += 1
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
}

// Preview provider for rendering WelcomeView in Xcode canvas.
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(showOnboarding: .constant(true))
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())
    }
}
