//
//  ScreenTimeView.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//


import SwiftUI

struct ScreenTimeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Today's Screen Time")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // Screen Time Summary Card
            VStack(alignment: .leading) {
                Text("Total Screen Time: 3h 45m")
                    .font(.headline)
                
                HStack {
                    AppUsageView(appName: "Instagram", usage: "1h 30m", color: .purple)
                    AppUsageView(appName: "TikTok", usage: "1h", color: .pink)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Screen Time Saved Progress Bar
            VStack(alignment: .leading) {
                Text("Time Saved by Fitness")
                    .font(.headline)
                
                ProgressBarView(progress: 0.6, color: .green)
                    .frame(height: 20)
            }
            .padding(.vertical)
            
            // Placeholder for App Management
            Button(action: {
                // Action for managing app restrictions
            }) {
                Text("Manage App Restrictions")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Screen Time")
    }
}

// Reusable App Usage View
struct AppUsageView: View {
    let appName: String
    let usage: String
    let color: Color
    
    var body: some View {
        VStack {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
            
            Text(appName)
                .font(.caption)
                .multilineTextAlignment(.center)
            
            Text(usage)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

// Reusable Progress Bar View
struct ProgressBarView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                Rectangle()
                    .frame(width: CGFloat(progress) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(color)
                    .animation(.linear, value: progress)
            }
            .cornerRadius(geometry.size.height / 2)
        }
    }
}
