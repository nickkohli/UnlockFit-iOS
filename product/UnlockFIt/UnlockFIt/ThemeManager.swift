// ThemeManager.swift: Manages the user’s selected colour theme, persists it, and applies it across the app UI.
import SwiftUI

// ThemeManager publishes theme changes and provides accent colours based on the selected theme.
class ThemeManager: ObservableObject {
    // The currently selected theme name; saving and applying whenever it changes.
    @Published var selectedTheme: String = "Default" {
        didSet {
            saveTheme()
            applyTheme()
        }
    }

    // Primary accent colour for UI elements based on the selected theme.
    var accentColor: Color {
        switch selectedTheme {
        case "Neon":
            return CustomColors.neonYellow
        case "Ulku":
            return CustomColors.ulkuBlue
        case "Performance":
            return CustomColors.performanceRed
        case "Slate":
            return CustomColors.slateGray
        case "Aurora":
            return CustomColors.auroraTeal
        case "Cyberpunk":
            return CustomColors.cyberpunkBlue
        default:
            return .purple
        }
    }

    // Secondary accent colour for gradients based on the selected theme.
    var accentColor2: Color {
        switch selectedTheme {
        case "Neon":
            return CustomColors.neonYellow2
        case "Ulku":
            return CustomColors.ulkuBlue2
        case "Performance":
            return CustomColors.performanceRed2
        case "Slate":
            return CustomColors.slateGray2
        case "Aurora":
            return CustomColors.auroraMagenta
        case "Cyberpunk":
            return CustomColors.cyberpunkPink
        default:
            return .pink
        }
    }

    // On initialisation, load saved theme and apply it immediately.
    init() {
        loadTheme()
        applyTheme()
    }

    // Apply the theme by updating system appearance (e.g., tab bar tint) and refreshing the UI.
    func applyTheme() {
        switch selectedTheme {
        case "Neon":
            UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.neonYellow2)
        case "Ulku":
            UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.ulkuBlue2)
        case "Performance":
            UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.performanceRed2)
        case "Slate":
            UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.slateGray2)
        case "Aurora":
            UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.auroraMagenta)
        case "Cyberpunk":
            UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.cyberpunkPink)
        default:
            UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
        }
        refreshUI()
    }

    // Refresh the root view controller to force UI to update with the new theme.
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

    // Persist the selected theme to UserDefaults.
    private func saveTheme() {
        UserDefaults.standard.set(selectedTheme, forKey: "SelectedTheme")
    }

    // Load the previously saved theme from UserDefaults, if any.
    private func loadTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: "SelectedTheme") {
            selectedTheme = savedTheme
        }
    }
}
