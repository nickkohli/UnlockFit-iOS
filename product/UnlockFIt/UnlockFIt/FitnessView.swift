import SwiftUI

struct FitnessView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animateRings: Bool = false // State to control animation
    @State private var hasAnimated: Bool = false // Tracks if animation has already been triggered
    
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
                        progress: animateRings ? 0.75 : 0, // Animate progress
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [CustomColors.ringRed, CustomColors.ringRed2]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    ProgressRingView(
                        title: "Calories",
                        progress: animateRings ? 0.5 : 0, // Animate progress
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [CustomColors.ringGreen, CustomColors.ringGreen2]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    ProgressRingView(
                        title: "Minutes",
                        progress: animateRings ? 0.9 : 0, // Animate progress
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
                        .background(LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor2]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Fitness")
        .onAppear {
            if !hasAnimated {
                triggerAnimation()
                hasAnimated = true
            }
        }
    }

    private func triggerAnimation() {
        DispatchQueue.main.async {
            animateRings = false // Reset animation
            withAnimation(.easeInOut(duration: 2.5)) { // Adjust duration here
                animateRings = true
            }
        }
    }
}

struct ProgressRingView: View {
    let title: String
    let progress: Double
    let gradient: LinearGradient

    var body: some View {
        VStack {
            ZStack {
                // Background ring
                Circle()
                    .stroke(lineWidth: 17)
                    .opacity(0.2)
                    .foregroundColor(.gray)

                // Animated progress ring
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(gradient, style: StrokeStyle(lineWidth: 17, lineCap: .round))
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.easeInOut(duration: 2.5), value: progress) // Smooth animation

                // Percentage text
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(width: 90.78, height: 100)

            // Title below the ring
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.top, 5)
        }
    }
}
