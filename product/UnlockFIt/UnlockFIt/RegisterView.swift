import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var nickname: String = ""
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showSuccess = false
    @State private var progressWidth: CGFloat = 0
    @State private var showSetupScreen = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

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

                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: {
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
                    
                    Button(action: {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController?.dismiss(animated: true, completion: nil)
                        }
                    }) {
                        Text("Already have an account? Log In")
                            .foregroundColor(.white.opacity(0.7))
                            .underline()
                            .font(.footnote)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    Button("Test Success Overlay") {
                        showSuccess = true
                    }
                    .foregroundColor(.gray)
                    .padding(.top, 10)

                }
                .padding()
            }
            .overlay(
                Group {
                    if showSuccess {
                        Color.black.opacity(0.85).edgesIgnoringSafeArea(.all)
                        VStack {
                            VStack(spacing: 10) {
                                Text("✅ Account Created")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)
                                Text("Let’s get you set up.")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.subheadline)

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
                        .onAppear {
                            progressWidth = 0
                            withAnimation(.easeInOut(duration: 3)) {
                                progressWidth = UIScreen.main.bounds.width * 0.6
                            }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                showSuccess = false
                                showSetupScreen = true
                            }
            }
            .fullScreenCover(isPresented: $showSetupScreen) {
                NotificationSetupView()
            }
        }
                }
            )
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(ThemeManager())
    }
}
