import SwiftUI
import FirebaseAuth

struct ThemesView: View {
    @EnvironmentObject var themeManager: ThemeManager

    let themes = ["Default", "Neon"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select a Theme")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 20)

            ForEach(themes, id: \.self) { theme in
                Toggle(
                    isOn: Binding<Bool>(
                        get: { themeManager.selectedTheme == theme },
                        set: { isOn in
                            if isOn {
                                themeManager.selectedTheme = theme
                                if let uid = Auth.auth().currentUser?.uid {
                                    FirestoreManager.shared.updateUserTheme(uid: uid, theme: theme)
                                }
                            }
                        }
                    )
                ) {
                    Text(theme)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor)) // Dynamic tint color
                .padding(.vertical, 5)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView()
    }
}
