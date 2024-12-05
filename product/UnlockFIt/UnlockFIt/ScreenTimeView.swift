//
//  ScreenTimeView.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//


import SwiftUI

struct ScreenTimeView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20) {
                Text("Today's Screen Time")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Screen Time Summary Card
                VStack(alignment: .leading) {
                    Text("Total Screen Time: 3h 45m")
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack {
                        AppUsageView(appName: "Instagram", usage: "1h 30m", color: .purple)
                        AppUsageView(appName: "TikTok", usage: "1h", color: .pink)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                // Progress Bar
                VStack(alignment: .leading) {
                    Text("Time Saved by Fitness")
                        .font(.headline)
                        .foregroundColor(.white)
                    ProgressBarView(progress: 0.6, color: .green)
                        .frame(height: 20)
                }
                .padding(.vertical)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                // Button
                Button(action: {
                    // Action
                }) {
                    Text("Manage App Restrictions")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color.pink, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
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
                .foregroundColor(Color.white)
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

struct ScreenTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenTimeView()
    }
}
