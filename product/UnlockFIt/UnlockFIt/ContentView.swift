//
//  CustomColors.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            MainTabView() // Show the main tab view if logged in
        } else {
            LoginView() // Show the login view if not logged in
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
    }
}
