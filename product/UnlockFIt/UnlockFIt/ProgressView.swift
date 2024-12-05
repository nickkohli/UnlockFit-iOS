//
//  ProgressView.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//


import SwiftUI

struct ProgressView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Your Progress")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Weekly Overview
                VStack(alignment: .leading) {
                    Text("Weekly Overview")
                        .font(.headline)
                    
                    HStack {
                        ProgressCard(title: "Steps", value: "56,000", color: .blue)
                        ProgressCard(title: "Calories", value: "3,500", color: .red)
                        ProgressCard(title: "Time Saved", value: "5h 20m", color: .green)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Trend Graph (Placeholder)
                VStack(alignment: .leading) {
                    Text("Fitness Trends")
                        .font(.headline)
                    
                    LineGraph(data: [50, 70, 90, 85, 95, 100, 110], color: .blue)
                        .frame(height: 200)
                }
                
                Spacer().frame(height: 20)
                
                // Achievements
                VStack(alignment: .leading) {
                    Text("Achievements")
                        .font(.headline)
                    
                    HStack {
                        AchievementBadge(title: "10k Steps", icon: "figure.walk", color: .blue)
                        AchievementBadge(title: "Screen Saver", icon: "clock", color: .green)
                        AchievementBadge(title: "Calorie Burner", icon: "flame", color: .red)
                    }
                }
            }
            .padding()
            .navigationTitle("Progress")
        }
    }
}

// Reusable Progress Card
struct ProgressCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
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
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}