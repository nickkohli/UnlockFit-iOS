//
//  ThemeManager.swift
//  UnlockFIt
//
//  Created by woozy on 06/12/2024.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var selectedTheme: String = "Default" {
        didSet {
            saveTheme() // Save the theme whenever it changes
            applyTheme()
        }
    }

    var accentColor: Color {
        selectedTheme == "Neon" ? CustomColors.neonYellow : .purple
    }

    var accentColor2: Color {
        selectedTheme == "Neon" ? CustomColors.neonYellow2 : .pink
    }

    init() {
        loadTheme() // Load the saved theme during initialization
        applyTheme() // Apply the loaded theme
    }

    func applyTheme() {
        switch selectedTheme {
        case "Neon":
            UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.neonYellow2)
        default:
            UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
        }

        // Notify the system to refresh the UI
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
