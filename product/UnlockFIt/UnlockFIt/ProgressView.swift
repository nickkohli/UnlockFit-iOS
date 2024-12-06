//
//  ProgressView.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//


import SwiftUI

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var themeManager: ThemeManager // Inject ThemeManager

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Progress")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Weekly Overview
                    VStack(alignment: .leading) {
                        Text("Weekly Overview")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
                            ProgressCard(title: "Steps", value: "56,000", color: CustomColors.ringRed)
                            ProgressCard(title: "Calories", value: "3,500", color: CustomColors.ringGreen)
                            ProgressCard(title: "Time Saved", value: "5h 20m", color: CustomColors.ringBlue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                    // Fitness Trends
                    VStack(alignment: .leading) {
                        Text("Fitness Trends")
                            .font(.headline)
                            .foregroundColor(.white)
                        LineGraph(data: [50, 70, 90, 85, 95, 100, 110], color: themeManager.accentColor) // Use dynamic accent color
                            .frame(height: 200)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                    // Achievements
                    VStack(alignment: .leading) {
                        Text("Achievements")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        HStack {
                            AchievementBadge(title: "10k Steps", icon: "figure.walk", color: CustomColors.bronze)
                            AchievementBadge(title: "Screen Saver", icon: "clock", color: CustomColors.silver)
                            AchievementBadge(title: "Calorie Burner", icon: "flame", color: CustomColors.gold)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

// Reusable Progress Card
struct ProgressCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack() {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.all, 12.0)
        .background(Color(red: 0.108, green: 0.108, blue: 0.114))
        
    }
}

// Placeholder Line Graph
struct LineGraph: View {
    let data: [Double]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(data.count - 1)
                let maxValue = data.max() ?? 1
                
                path.move(to: CGPoint(x: 0, y: height - CGFloat(data[0]) / CGFloat(maxValue) * height))
                
                for index in 1..<data.count {
                    let x = CGFloat(index) * step
                    let y = height - CGFloat(data[index]) / CGFloat(maxValue) * height
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(color, lineWidth: 2)
        }
    }
}

// Reusable Achievement Badge
struct AchievementBadge: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.all, 0.2)
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environmentObject(ThemeManager()) // Inject ThemeManager for preview
    }
}
