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
                    Spacer()
                }
                .padding()
            }
        }
    }
}

struct NotificationSetupView: View {
    var body: some View {
        Text("Let's set up your notifications!")
            .font(.title)
            .padding()
            .foregroundColor(.white)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(ThemeManager())
    }
}
