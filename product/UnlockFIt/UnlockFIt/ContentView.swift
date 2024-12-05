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
        }
        .accentColor(.green) // Set the theme color
    }
}

struct FitnessView: View {
    var body: some View {
        Text("Fitness Section")
    }
}

struct ScreenTimeView: View {
    var body: some View {
        Text("Screen Time Section")
    }
}

struct ProgressView: View {
    var body: some View {
        Text("Progress Section")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
