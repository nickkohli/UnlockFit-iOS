import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var goalManager: GoalManager
    @EnvironmentObject var screenTimeSessionManager: ScreenTimeSessionManager
    @EnvironmentObject var screenTimeHistoryManager: ScreenTimeHistoryManager
    
    @State private var username: String = "" // Email input
    @State private var password: String = "" // Password input
    @State private var showRegister = false
    @State private var loginError: String?
    @State private var isLoggingIn = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Background color

                VStack(spacing: 20) {
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

                    // Username Field (Email)
                    ZStack(alignment: .leading) {
                        if username.isEmpty {
                            Text("Email")
                                .foregroundColor(Color.white.opacity(0.5)) // Lightened placeholder text color
                                .padding(.leading, 15)
                        }
                        TextField("", text: $username)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                    }

                    // Password Field
                    ZStack(alignment: .leading) {
                        if password.isEmpty {
                            Text("Password")
                                .foregroundColor(Color.white.opacity(0.5)) // Lightened placeholder text color
                                .padding(.leading, 15)
                        }
                        SecureField("", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }

                    // Log In Button
                    Button(action: {
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
                                appState.isLoggedIn = true
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

                    // Register Button
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        showRegister = true
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .fullScreenCover(isPresented: $showRegister) {
                        RegisterView()
                            .environmentObject(themeManager)
                            .environmentObject(appState)
                            .environmentObject(goalManager)
                            .environmentObject(screenTimeSessionManager)
                            .environmentObject(screenTimeHistoryManager)
                    }

                    // Error Message
                    if let loginError = loginError {
                        Text(loginError)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                    }

                    Spacer() // Fills remaining space at the bottom
                }
                .padding()
                .navigationBarHidden(true) // Hide navigation bar
            }
        }
    }
}

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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())
    }
}
