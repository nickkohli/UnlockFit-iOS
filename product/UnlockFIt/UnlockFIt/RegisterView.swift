// RegisterView.swift: UI for user sign-up, validation, and onboarding flow with success overlay.
import SwiftUI
import UIKit
import FirebaseAuth
import FirebaseFirestore

// RegisterView presents input fields for nickname, email, password, and handles Firebase registration.
struct RegisterView: View {
    // Environment objects for theming, app state, and goal management.
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var goalManager: GoalManager
    
    // Local state for form values, error display, success overlay animation, and onboarding navigation.
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var nickname: String = ""
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showSuccess = false
    @State private var progressWidth: CGFloat = 0
    @State private var showSetupScreen = false
    
    // Binding to control whether the onboarding flow is presented.
    @Binding var showOnboarding: Bool

    // The view body builds the registration form, error messages, and success overlay.
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Header title for the registration screen.
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Input fields group: nickname, email, password, and confirm password.
                    Group {
                        TextField("", text: $nickname, prompt: Text("Nickname").foregroundColor(.white.opacity(0.6)))
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        
                        TextField("", text: $email, prompt: Text("Email").foregroundColor(.white.opacity(0.6)))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.6)))
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        SecureField("", text: $confirmPassword, prompt: Text("Confirm Password").foregroundColor(.white.opacity(0.6)))
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }

                    // Display validation or registration error messages.
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // Register button: validates inputs, triggers haptic feedback, and creates a Firebase Auth user.
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        showError = false
                        errorMessage = ""

                        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !nickname.isEmpty else {
                            errorMessage = "Please fill in all fields."
                            showError = true
                            return
                        }

                        guard email.contains("@"), email.contains(".") else {
                            errorMessage = "Please enter a valid email address."
                            showError = true
                            return
                        }

                        let nicknamePattern = "^[a-zA-Z0-9]{1,16}$"
                        let nicknameRegex = try! NSRegularExpression(pattern: nicknamePattern)
                        let range = NSRange(location: 0, length: nickname.utf16.count)
                        guard nicknameRegex.firstMatch(in: nickname, options: [], range: range) != nil else {
                            errorMessage = "Nickname must be 1-16 characters with no special symbols."
                            showError = true
                            return
                        }

                        guard password == confirmPassword else {
                            errorMessage = "Passwords do not match."
                            showError = true
                            return
                        }

                        Auth.auth().createUser(withEmail: email, password: password) { result, error in
                            if let error = error {
                                errorMessage = error.localizedDescription
                                showError = true
                                return
                            }

                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.displayName = nickname
                            changeRequest?.commitChanges(completion: nil)

                            DispatchQueue.main.async {
                                showSuccess = true
                            }

                            print("✅ Successfully registered user: \(email)")
                            
                            if let uid = result?.user.uid {
                                FirestoreManager.shared.saveNewUser(uid: uid, email: email, nickname: nickname)
                                print("📝 Firestore saveNewUser called for UID: \(uid)")
                            }
                        }
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(
                                gradient: Gradient(colors: [.purple, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Button to dismiss registration and return to the login screen.
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController?.dismiss(animated: true, completion: nil)
                        }
                    }) {
                        Text("Already have an account? Log In 🔑")
                            .foregroundColor(.white.opacity(0.7))
                            .underline()
                            .font(.footnote)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    // Debug button to show the account-created success overlay.
                    Button("Test Success Overlay") {
                        showSuccess = true
                    }
                    .foregroundColor(.gray)
                    .padding(.top, 10)

                }
                .padding()
            }
            // Overlay presenting a success confirmation and progress bar animation after registration.
            .overlay(
                Group {
                    // Conditionally show the success overlay with "Account Created" message.
                    if showSuccess {
                        Color.black.opacity(0.85).edgesIgnoringSafeArea(.all)
                        VStack {
                            VStack(spacing: 10) {
                                // Success title displayed when account creation succeeds.
                                Text("Account Created ✅")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)
                                // Subtitle prompting the user to proceed to notification setup.
                                Text("Let’s get you set up.")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.subheadline)

                                // Animated progress bar showing setup transition time.
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .frame(height: 6)
                                        .foregroundColor(Color.white.opacity(0.3))

                                    RoundedRectangle(cornerRadius: 5)
                                        .frame(width: progressWidth, height: 6)
                                        .foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.purple, .pink]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.3)))
                            .transition(.scale)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        // On appear, animate the progress bar and then transition to the notification setup screen.
                        .onAppear {
                            progressWidth = 0
                            withAnimation(.easeInOut(duration: 2.25)) {
                                progressWidth = UIScreen.main.bounds.width * 0.6
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                showSuccess = false
                                showSetupScreen = true
                            }
                        }
                    }
                }
            )
            // Full-screen cover to present the NotificationSetupView after successful registration.
            .fullScreenCover(isPresented: $showSetupScreen) {
                NotificationSetupView(showOnboarding: $showOnboarding)
                    .environmentObject(themeManager)
                    .environmentObject(appState)
                    .environmentObject(goalManager)
            }
        }
    }
}

// Preview provider for rendering RegisterView in Xcode canvas.
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(showOnboarding: .constant(true))
            .environmentObject(ThemeManager())
    }
}
