// ThemesView.swift: UI for selecting and persisting the app’s colour theme options.
import SwiftUI
// Import FirebaseAuth to update the user’s theme choice in Firestore.
import FirebaseAuth

// ThemesView displays a list of available themes and binds toggles to the ThemeManager.
struct ThemesView: View {
    // EnvironmentObject providing access to and control of the current theme settings.
    @EnvironmentObject var themeManager: ThemeManager

    // The list of theme identifiers available for user selection.
    // The list of theme identifiers available for user selection.
    let themes = ["Default", "Neon", "Ulku", "Performance", "Slate", "Aurora", "Cyberpunk"]

    // The view body lays out the header and a toggle for each theme option.
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header prompting the user to choose a theme.
            Text("Select a Theme")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 20)

            // Iterate through each theme and present a toggle switch bound to its selection state.
            ForEach(themes, id: \.self) { theme in
                // Toggle control: on when this theme is selected, off otherwise. Setting it updates ThemeManager and Firestore.
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
                // Apply the current theme’s accent colour to the toggle switch.
                .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                .padding(.vertical, 5)
            }
            
            // Spacer to push content to the top of the view.
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

// PreviewProvider for rendering ThemesView in Xcode canvas.
struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView()
    }
}
