//
//  CustomColors.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager

    init() {
        // Set the appearance of the Tab Bar globally
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }

    var body: some View {
        ZStack {
            // Set the background color based on the theme
            Color.black.edgesIgnoringSafeArea(.all)

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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ThemeManager()) // Inject ThemeManager for preview
    }
}
