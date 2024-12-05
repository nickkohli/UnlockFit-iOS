//
//  ContentView.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//

import SwiftUI

struct ContentView: View {
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
        .accentColor(.green) // Set the theme color
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
