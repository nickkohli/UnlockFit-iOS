//
//  MainTabView.swift
//  UnlockFIt
//
//  Created by woozy on 07/12/2024.
//


import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        TabView {
            FitnessView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Fitness")
                }

            ScreenTimeView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Screen Time")
                }

            ProgressView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Progress")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .accentColor(themeManager.accentColor) // Selected tab icon color
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(ThemeManager())
    }
}