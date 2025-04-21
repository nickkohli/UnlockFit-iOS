import SwiftUI

struct FitnessView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var goalManager: GoalManager
    @EnvironmentObject var appState: AppState
    @State private var animateRings: Bool = false // State to control animation
    @State private var hasAnimated: Bool = false // Tracks if animation has already been triggered
    @State private var isActive: Bool = true
    @State private var refreshTimer: Timer? = nil
    @State private var isRefreshing: Bool = false

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Let’s get moving, Nick!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(Date(), style: .date)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom)
        }
    }

    private var progressRingsSection: some View {
        HStack(spacing: 30) {
            ProgressRingView(
                title: "Steps",
                progress: animateRings
                    ? min(goalManager.stepsToday / Double(appState.stepGoal), 1.0)
                    : 0,
                gradient: LinearGradient(
                    gradient: Gradient(colors: [CustomColors.ringRed, CustomColors.ringRed2]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            ProgressRingView(
                title: "Calories",
                progress: animateRings ? min(goalManager.caloriesBurned / Double(appState.calorieGoal), 1.0) : 0,
                gradient: LinearGradient(gradient: Gradient(colors: [CustomColors.ringGreen, CustomColors.ringGreen2]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            ProgressRingView(
                title: "Minutes",
                progress: animateRings ? min(goalManager.minutesExercised / Double(appState.minuteGoal), 1.0) : 0,
                gradient: LinearGradient(gradient: Gradient(colors: [CustomColors.ringBlue, CustomColors.ringBlue2]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }

    var body: some View {
        ZStack {
            // Dark Background
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 10) { // Adjusted spacing
                // Greeting and Date Header
                greetingSection
                
                // Progress Rings Section
                progressRingsSection
                
                // Action Buttons
                Button(action: {
                    // Action for setting fitness goals
                }) {
                    Text("Set a Step Goal")
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor2]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.all)
                
                Spacer() // Added a Spacer at the bottom to fill remaining space
            }
            .padding(.horizontal) // Added horizontal padding for better alignment
            .padding(.top, 10) // Adjusted the padding at the top
            
            // Refresh Button floating bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        isRefreshing = true
                        goalManager.refreshWeeklyData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isRefreshing = false
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                            .animation(isRefreshing ? .easeInOut(duration: 1.0) : .default, value: isRefreshing)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true) // Hide the navigation bar title to save space
        .onAppear {
            print("\n")
            if !hasAnimated {
                triggerAnimation()
                hasAnimated = true
            }
            isActive = true
            print("🔄 FitnessView appeared: refreshing ring data immediately.")
            goalManager.refreshWeeklyData()
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                if isActive {
                    print("⏰ FitnessView timer: refreshing ring data.")
                    goalManager.refreshWeeklyData()
                } else {
                    print("🛑 FitnessView timer skipped – view not visible.")
                }
            }
        }
        .onDisappear {
            print("👋 Left FitnessView – stopping timer.")
            isActive = false
            refreshTimer?.invalidate()
            refreshTimer = nil
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

struct FitnessView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
            .environmentObject(ThemeManager()) // Inject ThemeManager for preview
            .environmentObject(GoalManager())
            .environmentObject(AppState())
    }
}
