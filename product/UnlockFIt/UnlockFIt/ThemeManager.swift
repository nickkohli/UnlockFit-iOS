import SwiftUI

class ThemeManager: ObservableObject {
    @Published var selectedTheme: String = "Default" {
        didSet {
            saveTheme()
            applyTheme()
        }
    }

    var accentColor: Color {
        switch selectedTheme {
        case "Neon":
            return CustomColors.neonYellow
        case "Ulku":
            return CustomColors.ulkuBlue
        default:
            return .purple
        }
    }

    var accentColor2: Color {
        switch selectedTheme {
        case "Neon":
            return CustomColors.neonYellow2
        case "Ulku":
            return CustomColors.ulkuBlue2
        default:
            return .pink
        }
    }

    init() {
        loadTheme()
        applyTheme()
    }

    func applyTheme() {
        switch selectedTheme {
        case "Neon":
            UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.neonYellow2)
        case "Ulku":
            UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.ulkuBlue2)
        default:
            UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
        }
        refreshUI()
    }

    private func refreshUI() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let rootViewController = window.rootViewController
                window.rootViewController = nil
                window.rootViewController = rootViewController
                window.makeKeyAndVisible()
            }
        }
    }

    // Save the theme to UserDefaults
    private func saveTheme() {
        UserDefaults.standard.set(selectedTheme, forKey: "SelectedTheme")
    }

    // Load the theme from UserDefaults
    private func loadTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: "SelectedTheme") {
            selectedTheme = savedTheme
        }
    }
}
