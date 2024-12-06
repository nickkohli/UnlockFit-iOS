//
//  FitnessView.swift
//  UnlockFit
//
//  Created by woozy on 05/12/2024.
//

import SwiftUI

struct FitnessView: View {
    var body: some View {
        ZStack {
            // Dark Background
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                // Greeting and Date Header
                Text("Let’s get moving, Nick!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white) // Text color on dark background
                    .padding(.vertical, 2.0)
                
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    
                
                Spacer().frame(height: 20)
                
                // Progress Rings Section
                HStack(spacing: 30) {
                    ProgressRingView(
                        title: "Steps",
                        progress: 0.75,
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [CustomColors.ringRed, CustomColors.ringRed2]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    ProgressRingView(
                        title: "Calories",
                        progress: 0.5,
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [CustomColors.ringGreen, CustomColors.ringGreen2]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    ProgressRingView(
                        title: "Minutes",
                        progress: 0.9,
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [CustomColors.ringBlue, CustomColors.ringBlue2]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                Spacer().frame(height: 20)
                
                // Action Buttons
                Button(action: {
                    // Action for setting fitness goals
                }) {
                    Text("Set a Step Goal")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [.pink, .purple]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Fitness")
    }
}

// Reusable Progress Ring View
struct ProgressRingView: View {
    let title: String
    let progress: Double
    let gradient: LinearGradient
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 17)
                    .opacity(0.2)
                    .foregroundColor(.gray) // Background ring color

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(gradient, style: StrokeStyle(lineWidth: 17, lineCap: .round))
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.easeInOut, value: progress)

                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.white) // Percentage text color
            }
            .frame(width: 90.78, height: 100)

            Text(title)
                .font(.caption)
                .foregroundColor(.white) // Title text color
                .padding(.top, 5)
        }
    }
}

struct FitnessView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
            .environmentObject(ThemeManager()) // Provide a basic ThemeManager
    }
}
