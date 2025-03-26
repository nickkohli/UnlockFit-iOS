import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState // Access AppState
    @State private var username: String = "" // Username input
    @State private var password: String = "" // Password input

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

                    // Username Field
                    ZStack(alignment: .leading) {
                        if username.isEmpty {
                            Text("Username")
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
                        DispatchQueue.main.async {
                            appState.isLoggedIn = true // Update AppState on login
                            print("isLoggedIn set to: \(appState.isLoggedIn)")
                        }
                    }) {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(
                                gradient: Gradient(colors: [.purple, .pink, ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Register Button
                    Button(action: {
                        // Placeholder action for Register
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Spacer() // Fills remaining space at the bottom
                }
                .padding()
                .navigationBarHidden(true) // Hide navigation bar
            }
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
