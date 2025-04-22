import Firebase
import FirebaseFirestore
import FirebaseAuth
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
    @State private var stepGoalArray: [Int] = [0, 0, 0, 0]
    @State private var calorieGoalArray: [Int] = [0, 0, 0, 0]
    @State private var flightsGoalArray: [Int] = [0, 0, 0, 0]
    @State private var milestoneLastUpdated: Date = Date()

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
                
                VStack(alignment: .leading, spacing: 25) {
                    Text("Goal Unlock Progress")
                        .font(.headline)
                        .foregroundColor(.white)

                    GoalMilestoneBar(
                        title: "Steps",
                        progress: min(goalManager.stepsToday / Double(appState.stepGoal), 1.0),
                        milestones: appState.stepMilestones,
                        gradient: LinearGradient(gradient: Gradient(colors: [CustomColors.ringRed2, CustomColors.ringRed]), startPoint: .leading, endPoint: .trailing)
                    )

                    GoalMilestoneBar(
                        title: "Calories",
                        progress: min(goalManager.caloriesBurned / Double(appState.calorieGoal), 1.0),
                        milestones: appState.calorieMilestones,
                        gradient: LinearGradient(gradient: Gradient(colors: [CustomColors.ringGreen2, CustomColors.ringGreen]), startPoint: .leading, endPoint: .trailing)
                    )

                    GoalMilestoneBar(
                        title: "Flights Climbed",
                        progress: min(goalManager.flightsClimbed / Double(appState.flightsClimbedGoal), 1.0),
                        milestones: appState.flightsMilestones,
                        gradient: LinearGradient(gradient: Gradient(colors: [CustomColors.ringBlue2, CustomColors.ringBlue]), startPoint: .leading, endPoint: .trailing)
                    )
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
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
                        goalManager.refreshWeeklyData {
                            refreshAndAnimateIfNeeded()
                            checkAndUpdateMilestones()
                            loadMilestoneState()
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
            goalManager.refreshWeeklyData {
                refreshAndAnimateIfNeeded(force: true)
                checkAndUpdateMilestones()
                loadMilestoneState()
            }
            showPermissionScreen = goalManager.isHealthPermissionMissing
            isActive = true
            print("🔄 FitnessView appeared: refreshing ring data immediately.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // refreshAndAnimateIfNeeded(force: true) is now handled in refreshWeeklyData closure above
            }
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                if isActive {
                    print("⏰ FitnessView timer: refreshing ring data.")
                    goalManager.refreshWeeklyData {
                        refreshAndAnimateIfNeeded()
                        checkAndUpdateMilestones()
                    }
                } else {
                    print("🛑 FitnessView timer skipped – view not visible.")
                }
            }
            // checkAndUpdateMilestones() and loadMilestoneState() are now handled above after refresh
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
    // MARK: - Milestone Helper Functions
    private func loadMilestoneState() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.stepGoalArray = data["stepGoalArray"] as? [Int] ?? [0, 0, 0, 0]
                self.calorieGoalArray = data["calorieGoalArray"] as? [Int] ?? [0, 0, 0, 0]
                self.flightsGoalArray = data["flightsGoalArray"] as? [Int] ?? [0, 0, 0, 0]
                if let timestamp = data["milestoneLastUpdated"] as? Timestamp {
                    self.milestoneLastUpdated = timestamp.dateValue()
                }
                print("✅ Milestone arrays loaded from Firestore.")
                
                self.appState.stepMilestones = self.stepGoalArray
                self.appState.calorieMilestones = self.calorieGoalArray
                self.appState.flightsMilestones = self.flightsGoalArray
                print("✅ stepMilestones synced: \(self.appState.stepMilestones)")
            } else {
                print("❌ Failed to load milestone arrays.")
            }
        }
    }

    private func checkAndUpdateMilestones() {
        let today = Calendar.current.startOfDay(for: Date())
        if Calendar.current.startOfDay(for: milestoneLastUpdated) != today {
            print("🔁 New day detected. Resetting milestone arrays.")
            stepGoalArray = [0, 0, 0, 0]
            calorieGoalArray = [0, 0, 0, 0]
            flightsGoalArray = [0, 0, 0, 0]
            milestoneLastUpdated = today
            saveMilestoneState()
        }

        updateArrayIfNeeded(progress: goalManager.stepsToday / Double(appState.stepGoal), array: &stepGoalArray)
        updateArrayIfNeeded(progress: goalManager.caloriesBurned / Double(appState.calorieGoal), array: &calorieGoalArray)
        updateArrayIfNeeded(progress: goalManager.flightsClimbed / Double(appState.flightsClimbedGoal), array: &flightsGoalArray)
        
        appState.stepMilestones = stepGoalArray
        appState.calorieMilestones = calorieGoalArray
        appState.flightsMilestones = flightsGoalArray

        saveMilestoneState()
    }

    private func updateArrayIfNeeded(progress: Double, array: inout [Int]) {
        let thresholds: [Double] = [0.25, 0.5, 0.75, 1.0]
        for (index, threshold) in thresholds.enumerated() {
            if progress >= threshold && array[index] == 0 {
                array[index] = 1
                print("🎯 Milestone hit at \(Int(threshold * 100))% → updating array.")
            }
        }
    }

    private func saveMilestoneState() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([
            "stepGoalArray": stepGoalArray,
            "calorieGoalArray": calorieGoalArray,
            "flightsGoalArray": flightsGoalArray,
            "milestoneLastUpdated": Timestamp(date: milestoneLastUpdated)
        ]) { error in
            if let error = error {
                print("❌ Failed to save milestone arrays: \(error.localizedDescription)")
            } else {
                print("✅ Milestone arrays saved to Firestore.")
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

struct GoalMilestoneBar: View {
    let title: String
    let progress: Double
    let milestones: [Int] // 0 = unhit, 1 = hit, 2 = used
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .foregroundColor(.white)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 10)

                RoundedRectangle(cornerRadius: 7)
                    .fill(gradient)
                    .frame(width: CGFloat(progress) * UIScreen.main.bounds.width * 0.85, height: 10)

                // Dot markers
                GeometryReader { geometry in
                    let barWidth = geometry.size.width
                    let dotSize: CGFloat = 11
                    let offsets: [CGFloat] = [0.25, 0.5, 0.75, 1.0].map { $0 * barWidth - dotSize / 2 }

                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .frame(width: dotSize, height: dotSize)
                            .foregroundColor(
                                milestones[i] == 0 ? Color.gray.opacity(0.3) :
                                milestones[i] == 1 ? Color.white :
                                Color.gray
                            )
                            .offset(x: offsets[i], y: 7) // Adjust Y-offset if needed
                    }
                }
            }
            .frame(height: 25) // Ensure there's space for both bar and dots
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
