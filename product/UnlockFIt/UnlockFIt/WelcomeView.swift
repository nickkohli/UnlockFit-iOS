import SwiftUI
import ConfettiSwiftUI

struct WelcomeView: View {
    @State private var confettiCounter = 0
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var goalManager: GoalManager
    
    @Binding var showOnboarding: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()
                VStack(spacing: 10) {
                    Text("Welcome to UnlockFit! 🎉")
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
        WelcomeView(showOnboarding: .constant(true))
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())
    }
}
