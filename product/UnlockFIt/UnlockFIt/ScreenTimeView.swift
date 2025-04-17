import SwiftUI

struct ScreenTimeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenTimeManager: ScreenTimeSessionManager
    @State private var animatedProgress: Double = 0.0 // State to manage progress animation
    @State private var hasAnimated: Bool = false // Tracks if animation has already been triggered

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 15) { // Adjusted spacing
                // Header
                Text("Today's Screen Time")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 5) // Reduced bottom padding

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
                    ProgressBarView(progress: animatedProgress, color: .green)
                        .frame(height: 20)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                if true {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Custom Screen Time Session")
                            .font(.headline)
                            .foregroundColor(.white)

                        VStack(alignment: .leading) {
                            Text("Duration: \(Int(screenTimeManager.sessionDuration / 60)) min")
                                .foregroundColor(.gray)
                            Slider(value: Binding(
                                get: { screenTimeManager.sessionDuration / 60 },
                                set: { screenTimeManager.sessionDuration = $0 * 60 }
                            ), in: 0.05...60, step: 5)
                                .accentColor(themeManager.accentColor)
                                .onAppear {
                                    if screenTimeManager.sessionDuration < 300 {
                                        screenTimeManager.sessionDuration = 300
                                    }
                                }
                        }

                        if screenTimeManager.isSessionActive {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(screenTimeManager.timeRemaining > 0 ?
                                     "\(screenTimeManager.isPaused ? "⏸️" : "⏳") Time Remaining: \(Int(screenTimeManager.timeRemaining / 60)) min \(Int(screenTimeManager.timeRemaining.truncatingRemainder(dividingBy: 60))) sec" :
                                     "🛑 Time's up! Tap 'Stop Session' to clock out.")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .padding(.bottom, 5)
                                    .transition(.opacity.combined(with: .move(edge: .top)))

                                if screenTimeManager.timeRemaining > 0 {
                                    Button(action: {
                                        if screenTimeManager.isPaused {
                                            screenTimeManager.resumeSession()
                                        } else {
                                            screenTimeManager.pauseSession()
                                        }
                                    }) {
                                        Text(screenTimeManager.isPaused ? "Resume Session" : "Pause Session")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .animation(.easeInOut(duration: 0.4), value: screenTimeManager.timeRemaining)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Button(action: {
                            if screenTimeManager.isSessionActive {
                                screenTimeManager.stopSession()
                            } else {
                                if screenTimeManager.sessionDuration >= 3 {
                                    screenTimeManager.startSession(duration: screenTimeManager.sessionDuration)
                                }
                            }
                        }) {
                            Text(screenTimeManager.isSessionActive ? "Stop Session" : "Start Session")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor2]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.4), value: screenTimeManager.isSessionActive)
                }

                Spacer() // Fills remaining space at the bottom
            }
            .padding(.horizontal) // Horizontal padding for alignment
            .padding(.top, 10) // Slight top padding to ensure it’s not too close
        }
        .navigationTitle("")
        .navigationBarHidden(true) // Remove the navigation bar to save space
        .onAppear {
            if !hasAnimated {
                triggerAnimation()
                hasAnimated = true
            }
        }
    }

    private func triggerAnimation() {
        DispatchQueue.main.async {
            animatedProgress = 0.0 // Reset progress
            withAnimation(.easeInOut(duration: 4.0)) { // Slow down animation duration
                animatedProgress = 0.6 // Target progress
            }
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
                    .animation(.easeInOut(duration: 2.0), value: progress) // Matches the duration of the animation
            }
            .cornerRadius(geometry.size.height / 2)
        }
    }
}

struct ScreenTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenTimeView()
            .environmentObject(ThemeManager()) // Inject ThemeManager for preview
            .environmentObject(GoalManager())
    }
}
