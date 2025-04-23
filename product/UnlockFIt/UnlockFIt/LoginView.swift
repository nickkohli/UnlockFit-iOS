// LoginView.swift: UI for logging in or navigating to registration, with form validation and error handling.
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit

// LoginView handles user authentication: input fields, validation, and Firebase sign-in.
struct LoginView: View {
    // Environment objects for theming, app state, and health goals.
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var goalManager: GoalManager
    
    @ObservedObject var profileViewModel: ProfileViewModel
    
    // Local state for form inputs, loading indicator, errors, and navigation.
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginError: String?
    @State private var isLoggingIn = false
    @State private var showOnboarding = false

    // The view body constructs the login form, buttons, and handles user interactions.
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // App title with branded gradient treatment.
                    // App Title
                    HStack(spacing: 0) {
                        // "Unlock" in white
                        Text("Unlock")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        // "Fit" with gradient
                        Text("Fit")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .pink]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Text("Fit")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                )
                            )
                    }
                    .padding(.bottom, 40)

                    // Email input field with placeholder.
                    // Username Field (Email)
                    ZStack(alignment: .leading) {
                        if username.isEmpty {
                            Text("Email")
                                .foregroundColor(Color.white.opacity(0.5))
                                .padding(.leading, 15)
                        }
                        TextField("", text: $username)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                    }

                    // Password input field with secure entry.
                    // Password Field
                    ZStack(alignment: .leading) {
                        if password.isEmpty {
                            Text("Password")
                                .foregroundColor(Color.white.opacity(0.5))
                                .padding(.leading, 15)
                        }
                        SecureField("", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }

                    // Button to validate input and sign in via Firebase Auth.
                    // Log In Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        isLoggingIn = true
                        loginError = nil
                        
                        let emailPattern = #"^\S+@\S+\.\S+$"#
                        let emailRegex = try! NSRegularExpression(pattern: emailPattern)
                        let range = NSRange(location: 0, length: username.utf16.count)
                        if emailRegex.firstMatch(in: username, options: [], range: range) == nil {
                            loginError = "Please enter a valid email address."
                            isLoggingIn = false
                            return
                        }
                        
                        Auth.auth().signIn(withEmail: username, password: password) { authResult, error in
                            isLoggingIn = false
                            if let error = error {
                                isLoggingIn = false

                                if let errCode = AuthErrorCode(rawValue: (error as NSError).code) {
                                    switch errCode {
                                    default:
                                        loginError = "Invalid email or password."
                                    }
                                } else {
                                    loginError = "Unexpected error: \(error.localizedDescription)"
                                }

                                print("⚠️ Firebase Auth Error: \(error.localizedDescription)")
                            } else if authResult != nil {
                                
                                profileViewModel.fetchUserData()
                                
                                appState.isLoggedIn = true
                                
                                guard let uid = authResult?.user.uid else {
                                    print("❌ Could not find UID after login")
                                    return
                                }

                                FirestoreManager.shared.fetchUserData(uid: uid) { userData, error in
                                    if let error = error {
                                        print("❌ Failed to fetch user data: \(error.localizedDescription)")
                                        return
                                    }
                                    if let data = userData {
                                        appState.stepGoal = data["stepGoal"] as? Int ?? appState.stepGoal
                                        appState.calorieGoal = data["calorieGoal"] as? Int ?? appState.calorieGoal
                                        appState.flightsClimbedGoal = data["flightsClimbedGoal"] as? Int ?? appState.flightsClimbedGoal
                                        
                                        if let theme = data["theme"] as? String {
                                            themeManager.selectedTheme = theme
                                        }

                                        print("☁️ User profile loaded and applied from Firestore.")
                                    } else {
                                        print("⚠️ No user data found in Firestore.")
                                    }
                                }
                                
                                print("✅ Login successful. isLoggedIn set to true")
                            } else {
                                loginError = "Unknown login error occurred."
                                print("⚠️ Unknown error during login.")
                            }
                        }
                    }) {
                        if isLoggingIn {
                            HStack {
                                Spacer()
                                ProgressCircle()
                                Text("Logging in...")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding()
                            .background(LinearGradient(
                                gradient: Gradient(colors: [.purple, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .cornerRadius(10)
                        } else {
                            Text("Log In")
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
                    }
                    .disabled(isLoggingIn)

                    // Button to open registration flow.
                    // Register Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        showOnboarding = true
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .fullScreenCover(isPresented: $showOnboarding) {
                        RegisterView(showOnboarding: $showOnboarding)
                            .environmentObject(themeManager)
                            .environmentObject(appState)
                            .environmentObject(goalManager)
                    }

                    // Display login error messages to the user.
                    // Error Message
                    if let loginError = loginError {
                        Text(loginError)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                    }

                    Spacer()
                }
                .padding()
                .navigationBarHidden(true)
            }
        }
    }
}

// ProgressCircle shows a spinning loader during login.
struct ProgressCircle: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1)
            .stroke(AngularGradient(gradient: Gradient(colors: [.white, .pink]), center: .center), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: 20, height: 20)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

// Preview provider for the LoginView.
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(profileViewModel: ProfileViewModel())
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())
    }
}
