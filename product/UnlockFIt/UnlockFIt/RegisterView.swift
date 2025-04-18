import SwiftUI

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
                        // TODO: Validate input and call Firebase registration
                        // if passwords match && email valid:
                        // Auth.auth().createUser...
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(ThemeManager())
    }
}
