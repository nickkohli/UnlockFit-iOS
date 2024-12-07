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
    @StateObject private var appState = AppState() // Add AppState

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(appState) // Inject AppState into the environment
        }
    }
}
