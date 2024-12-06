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
            applyTheme()
        }
    }

    var accentColor: Color {
        selectedTheme == "Neon" ? CustomColors.neonYellow : .purple
    }
    var accentColor2: Color {
        selectedTheme == "Neon" ? CustomColors.neonYellow2 : .pink
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
}
