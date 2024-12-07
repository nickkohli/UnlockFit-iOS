import SwiftUI

struct LoginView: View {
    @State private var username: String = "" // Username input
    @State private var password: String = "" // Password input
    @State private var isLoggedIn: Bool = false // Track login state

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Background color

                VStack(spacing: 20) {
                    // App Title
                    Text("UnlockFit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)

                    // Username Field
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .autocapitalization(.none)

                    // Password Field
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    // Log In Button
                    Button(action: {
                        isLoggedIn = true // Simulate login
                    }) {
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
            .fullScreenCover(isPresented: $isLoggedIn) {
                MainTabView() // Navigate to MainTabView after login
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(ThemeManager())
    }
}
