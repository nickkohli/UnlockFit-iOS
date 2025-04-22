import Firebase
import SwiftUI

struct FitnessView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var goalManager: GoalManager
    @EnvironmentObject var appState: AppState
    @StateObject var profileViewModel = ProfileViewModel()
    @State private var animateRings: Bool = false // State to control animation
    @State private var hasAnimated: Bool = false // Tracks if animation has already been triggered
    @State private var isActive: Bool = true
    @State private var refreshTimer: Timer? = nil
    @State private var isRefreshing: Bool = false
    @State private var showGreeting: Bool = false
    @State private var lastSteps: Double = 0
    @State private var lastCalories: Double = 0
    @State private var lastFlights: Double = 0
    @State private var showPermissionScreen: Bool = false

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0) {
                Text("Let’s move")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if !profileViewModel.nickname.isEmpty {
                    Text(", ")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(profileViewModel.nickname)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [themeManager.accentColor, themeManager.accentColor2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text("!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }

            Text(Date(), style: .date)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom)
        }
        .opacity(showGreeting ? 1 : 0)
        .offset(x: showGreeting ? 0 : -40)
        .animation(.easeOut(duration: 1.0), value: showGreeting)
    }

    private var progressRingsSection: some View {
        VStack (spacing: 15) {
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
                    title: "Flights",
                    progress: animateRings ? min(goalManager.flightsClimbed / Double(appState.flightsClimbedGoal), 1.0) : 0,
                    gradient: LinearGradient(gradient: Gradient(colors: [CustomColors.ringBlue, CustomColors.ringBlue2]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)

            // Milestone Progress Bars
            VStack(alignment: .leading, spacing: 1) {
                Text("Goal Unlock Progress")
                    .font(.headline)
                    .foregroundColor(.white)

                MilestoneProgressView(title: "Steps", progress: goalManager.stepsToday / Double(appState.stepGoal), checkpointStates: goalManager.stepGoalArray, gradient: LinearGradient(gradient: Gradient(colors: [CustomColors.ringRed, CustomColors.ringRed2]), startPoint: .leading, endPoint: .trailing))

                MilestoneProgressView(title: "Calories", progress: goalManager.caloriesBurned / Double(appState.calorieGoal), checkpointStates: goalManager.calorieGoalArray, gradient: LinearGradient(gradient: Gradient(colors: [CustomColors.ringGreen, CustomColors.ringGreen2]), startPoint: .leading, endPoint: .trailing))

                MilestoneProgressView(title: "Flights", progress: goalManager.flightsClimbed / Double(appState.flightsClimbedGoal), checkpointStates: goalManager.flightsGoalArray, gradient: LinearGradient(gradient: Gradient(colors: [CustomColors.ringBlue, CustomColors.ringBlue2]), startPoint: .leading, endPoint: .trailing))

                if let nextMilestone = goalManager.closestMilestone {
                    Text("Next likely session: \(Int(nextMilestone.percentage))% of \(nextMilestone.metric.capitalized)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text("Next session unlocks when a milestone is hit.")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .animation(.easeInOut(duration: 0.6), value: goalManager.closestMilestone != nil)
        }
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
                        refreshAndAnimateIfNeeded()
                        isRefreshing = false
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
        .fullScreenCover(isPresented: $showPermissionScreen) {
            HealthPermissionView(isVisible: $showPermissionScreen)
        }
        .navigationTitle("")
        .navigationBarHidden(true) // Hide the navigation bar title to save space
        .onAppear {
            print("\n")
            if !hasAnimated {
                hasAnimated = true
                profileViewModel.fetchNickname { _ in }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showGreeting = true
                }
            }
            goalManager.refreshWeeklyData()
            showPermissionScreen = goalManager.isHealthPermissionMissing
            isActive = true
            print("🔄 FitnessView appeared: refreshing ring data immediately.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                refreshAndAnimateIfNeeded(force: true)
            }
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                if isActive {
                    print("⏰ FitnessView timer: refreshing ring data.")
                    goalManager.refreshWeeklyData()
                    refreshAndAnimateIfNeeded()
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

    private func refreshAndAnimateIfNeeded(force: Bool = false) {
        let currentSteps = goalManager.stepsToday
        let currentCalories = goalManager.caloriesBurned
        let currentFlights = goalManager.flightsClimbed

        print("🔍 Refresh check – Steps: \(currentSteps) (was \(lastSteps)), Calories: \(currentCalories) (was \(lastCalories)), Flights: \(currentFlights) (was \(lastFlights))")

        let didChange = currentSteps != lastSteps || currentCalories != lastCalories || currentFlights != lastFlights

        if didChange || force {
            print("✅ Data changed – triggering animation.")
            lastSteps = currentSteps
            lastCalories = currentCalories
            lastFlights = currentFlights
            withAnimation(.easeInOut(duration: 2.5)) {
                animateRings = true
            }
        } else {
            print("⏸ No data change – animation skipped.")
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
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.5), value: progress)
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

struct MilestoneProgressView: View {
    let title: String
    let progress: Double
    let checkpointStates: [Int]
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.caption)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(gradient)
                        .frame(width: CGFloat(min(progress, 1.0)) * geometry.size.width, height: 10)

                    ForEach(0..<4) { i in
                        let milestonePercentages: [CGFloat] = [0.25, 0.5, 0.75, 1.0]
                        let xOffset = milestonePercentages[i] * geometry.size.width

                        Circle()
                            .fill(progress >= milestonePercentages[i] ? Color.white : Color.white.opacity(0.3))
                            //.scaleEffect(checkpointStates[i] == 1 ? 1.2 : 1.0) // No longer needed
                            .position(x: xOffset, y: 5)
                            .animation(.easeInOut(duration: 0.5), value: progress)
                    }
                }
                .frame(height: 10)
            }
            .frame(height: 20)
        }
        .padding(.vertical, 8)
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
