//
//  UnlockFItApp.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//

import SwiftUI
import UIKit

@main
struct UnlockFitApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager) // Inject into the entire app
        }
    }
}
