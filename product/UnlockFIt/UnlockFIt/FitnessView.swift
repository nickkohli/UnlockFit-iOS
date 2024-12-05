//
//  FitnessView.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//


import SwiftUI

struct FitnessView: View {
    var body: some View {
        VStack(alignment: .leading) {
            // Greeting and Date Header
            Text("Let’s get moving, Nick!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text(Date(), style: .date)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer().frame(height: 20)
            
            // Progress Rings Section
            HStack(spacing: 30) {
                ProgressRingView(title: "Steps", progress: 0.75, color: .blue)
                ProgressRingView(title: "Calories", progress: 0.5, color: .red)
                ProgressRingView(title: "Minutes", progress: 0.9, color: .green)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            
            Spacer().frame(height: 20)
            
            // Action Buttons
            Button(action: {
                // Action for setting fitness goals
            }) {
                Text("Set a Step Goal")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Fitness")
    }
}

// Reusable Progress Ring View
struct ProgressRingView: View {
    let title: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.2)
                    .foregroundColor(color)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.easeInOut, value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.headline)
            }
            .frame(width: 100, height: 100)
            
            Text(title)
                .font(.caption)
                .padding(.top, 5)
        }
    }
}

struct FitnessView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
    }
}
