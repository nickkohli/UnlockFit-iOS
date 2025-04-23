// ScreenTimeView.swift: Main UI for displaying today’s screen-time summary, weekly trends, and session controls.
import Firebase
import FirebaseFirestore
import FirebaseAuth
// Uses SwiftUI for layout and UIKit for haptic feedback.
import SwiftUI
import UIKit

// ScreenTimeView displays summary cards, bar charts, custom session controls, and lock overlay.
struct ScreenTimeView: View {
    // Environment objects for theming, session/history managers, app state, and state for animations, refresh, and overlays.
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenTimeManager: ScreenTimeSessionManager
    @EnvironmentObject var historyManager: ScreenTimeHistoryManager
    @EnvironmentObject var appState: AppState
    @State private var animatedProgress: Double = 0.0
    @State private var hasAnimated: Bool = false
    @AppStorage("screenTimeBarDidAnimate") private var didAnimateInitialBar: Bool = false
    @State private var isRefreshing: Bool = false
    @State private var scrollID: String? = nil
    @State private var scrollAnchor: UnitPoint = .bottom
    @State private var isActive: Bool = true
    @State private var showOverlay: Bool = true

    // ChartType toggles between displaying seconds or session counts in the weekly bar chart.
    enum ChartType {
        case seconds, sessions
    }

    @State private var chartType: ChartType = .seconds
    @State private var selectedIndex: Int? = nil


    // Compute total screen time seconds for today from historyManager.
    var totalTime: TimeInterval {
        historyManager.getTodayScreenTime()
    }

    var totalHours: Int {
        Int(totalTime) / 3600
    }
    
    var totalMinutes: Int {
        (Int(totalTime) % 3600) / 60
    }
    
    var totalSeconds: Int {
        Int(totalTime) % 60
    }
    
    var formattedPercentage: String {
        String(format: "%.2f", (totalTime / 18000.0) * 100)
    }

    // Compute total number of screen-time sessions for today.
    var totalSessions: Int {
        historyManager.getTodaySessionCount()
    }

    // Compute progress toward the average usage baseline (5 hours) for the progress bar.
    var progress: Double {
        min(max(1.0 - (totalTime / 18000.0), 0.0), 1.0)
    }

    // Body builds the scrollable content: summary card, progress bar, weekly chart, custom session controls, and overlay.
    var body: some View {
        let calendar = Calendar.current
        let todayIndex = calendar.component(.weekday, from: Date()) - 1
        let allWeekdays = calendar.shortWeekdaySymbols
        let weekLabels = (0..<7).map { i in
            let index = (todayIndex - (6 - i) + 7) % 7
            return i == 6 ? "TODAY" : allWeekdays[index].uppercased()
        }
        let secondsArray = (0..<7).map { historyManager.screenTimeSeconds[6 - $0] }
        let sessionsArray = (0..<7).map { historyManager.screenTimeSessions[6 - $0] }
        let dataArray = chartType == .seconds ? secondsArray : sessionsArray
        let nonZeroMax = dataArray.max() ?? 0
        let maxVal = nonZeroMax > 0 ? nonZeroMax : 1

        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header title showing “Screen Time”.
                Text("Screen Time")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 17)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .background(Color.black)
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 15) {
                            Spacer().frame(height: 1).id("TopAnchor")
                            
                            // Summary card: shows total time and session count with a manual refresh button.
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(" 📱 Total Screen Time: \(totalHours)h \(totalMinutes)m \(totalSeconds)s")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Sessions Today: \(totalSessions)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    isRefreshing = true
                                    historyManager.loadFromFirestore {
                                        historyManager.refreshDailyTrackingArraysIfNeeded()
                                        historyManager.saveToFirestore()
                                        triggerAnimation()
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        isRefreshing = false
                                    }
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                                        .animation(isRefreshing ? .easeInOut(duration: 1.0) : .default, value: isRefreshing)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.3))
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            
                            // Progress bar comparing today’s usage to average adult usage (5 hours).
                            VStack(alignment: .leading) {
                                Text("Time Saved Compared to Average ⏰")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                ProgressBarView(progress: animatedProgress, color: .green)
                                    .frame(height: 20)
                                    .onAppear {
                                        if !didAnimateInitialBar {
                                            animatedProgress = 0.0
                                            withAnimation(.easeInOut(duration: 2.0)) {
                                                animatedProgress = progress
                                            }
                                            didAnimateInitialBar = true
                                        }
                                    }
                                Text("You’ve used screen time for \(totalHours)h \(totalMinutes)m \(totalSeconds)s across \(totalSessions) session(s) today — that’s just \(formattedPercentage)% of the average adult.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            
                            // Weekly chart section: bar chart of screen-time or session counts over the last 7 days.
                            VStack(alignment: .leading) {
                                let hasNonZero = dataArray.contains(where: { $0 > 0 })
                                Group {
                                    if hasNonZero {
                                        // Section header for the weekly bar chart, switching label based on chartType.
                                        HStack {
                                            Text(chartType == .seconds ? "Screen Time (last 7 days) 📅" : "Sessions (last 7 days) 🗓️")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Button(action: {
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                                chartType = chartType == .seconds ? .sessions : .seconds
                                            }) {
                                                Image(systemName: "arrow.left.arrow.right")
                                                    .foregroundColor(.white)
                                            }
                                        }

                                        HStack(alignment: .bottom, spacing: 6) {
                                            // Generate each bar and label for the 7-day chart, with tap-to-select for details.
                                            ForEach(0..<7, id: \.self) { i in
                                                let val = dataArray[i]
                                                let barHeight = hasNonZero ? CGFloat(val) / CGFloat(maxVal) * 100 : 0.001
                                                VStack {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .fill(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: selectedIndex == i
                                                                                   ? [themeManager.accentColor2, themeManager.accentColor]
                                                                                   : [Color.gray.opacity(0.4), Color.gray.opacity(0.4)]),
                                                                startPoint: .top,
                                                                endPoint: .bottom
                                                            )
                                                        )
                                                        .frame(height: barHeight)
                                                        .onTapGesture {
                                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                                            generator.impactOccurred()
                                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                                selectedIndex = selectedIndex == i ? nil : i
                                                                scrollAnchor = .bottom
                                                                scrollID = "ScrollBottom"
                                                            }
                                                        }

                                                    Text(weekLabels[i])
                                                        .font(.caption2)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                        .frame(height: 120)
                                        .animation(.easeInOut(duration: 0.4), value: chartType)

                                        // Detail box showing exact time or session count for the selected day.
                                        if let index = selectedIndex {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(weekLabels[index])
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                if chartType == .seconds {
                                                    let h = dataArray[index] / 3600
                                                    let m = (dataArray[index] % 3600) / 60
                                                    let s = dataArray[index] % 60
                                                    Text("Time: \(h)h \(m)m \(s)s")
                                                        .font(.caption2)
                                                        .foregroundColor(.gray)
                                                } else {
                                                    Text("Sessions: \(dataArray[index]) session\(dataArray[index] == 1 ? "" : "s")")
                                                        .font(.caption2)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            .padding(.top, 4)
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                            .animation(.easeInOut(duration: 0.3), value: selectedIndex)
                                        }
                                    }
                                    if !hasNonZero {
                                        Text("No screen time data available yet.\nStart a session to begin tracking.")
                                            .foregroundColor(.gray)
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity, minHeight: 120)
                                            .multilineTextAlignment(.center)
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .animation(.easeInOut(duration: 0.4), value: dataArray.contains(where: { $0 > 0 }))
                            .cornerRadius(10)
                            
                            // Custom session controls: slider to choose duration and buttons to start/pause/resume/stop.
                            ZStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Custom Screen Time Session 🕒")
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
                                                    "🛑 Time's up! But we’re still counting ⏱️ Tap 'Stop Session' to log your screen time.")
                                                .foregroundColor(.white)
                                                .font(.subheadline)
                                                .padding(.bottom, 5)
                                                .transition(.opacity.combined(with: .move(edge: .top)))

                                            if screenTimeManager.timeRemaining > 0 {
                                                Button(action: {
                                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                                    generator.impactOccurred()
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

                                    VStack {
                                        if screenTimeManager.isPaused {
                                            Color.clear
                                                .frame(height: 0)
                                                .transition(.opacity.combined(with: .move(edge: .top)))
                                        } else {
                                            Button(action: {
                                                let generator = UINotificationFeedbackGenerator()
                                                if screenTimeManager.isSessionActive {
                                                    generator.notificationOccurred(.success)
                                                    screenTimeManager.stopSession()
                                                    historyManager.saveScreenTimeHistory()
                                                    markMilestonesUsed()
                                                    scrollAnchor = .top
                                                    scrollID = "TopAnchor"
                                                } else {
                                                    generator.notificationOccurred(.success)
                                                    if screenTimeManager.sessionDuration >= 3 {
                                                        screenTimeManager.startSession(duration: screenTimeManager.sessionDuration)
                                                        scrollAnchor = .bottom
                                                        scrollID = "ScrollBottom"
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
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                        }
                                    }
                                    .animation(.easeInOut(duration: 0.4), value: screenTimeManager.isPaused)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .animation(.easeInOut(duration: 0.4), value: (screenTimeManager.isSessionActive || screenTimeManager.isPaused))

                                // Overlay view locking screen-time controls until fitness milestones are met.
                                if showOverlay {
                                    ZStack {
                                        Color.black.opacity(0.6)
                                            .cornerRadius(10)
                                        VStack(spacing: 8) {
                                            Image(systemName: "lock.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(.white)
                                            Text("Screen time locked till you hit your next fitness goal")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.3), value: showOverlay)
                                }
                            }
                            
                            Spacer().frame(height: 0).id("ScrollBottom")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .onChange(of: scrollID) { _, newID in
                            guard let id = newID else { return }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo(id, anchor: scrollAnchor)
                            }
                            scrollID = nil
                        }
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            print("\n")
            isActive = true
            if !hasAnimated {
                triggerAnimation()
                hasAnimated = true
            }
            print("🔄 ScreenTimeView appeared: refreshing screen data immediately.")
            historyManager.loadFromFirestore {
                    historyManager.refreshDailyTrackingArraysIfNeeded()
                    historyManager.saveToFirestore()
                }
            updateOverlayState()
        }
        .onChange(of: appState.stepMilestones) { _, _ in updateOverlayState() }
        .onChange(of: appState.calorieMilestones) { _, _ in updateOverlayState() }
        .onChange(of: appState.flightsMilestones) { _, _ in updateOverlayState() }
        .onDisappear {
            print("👋 Left ScreenTimeView – stopping timer")
            isActive = false
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            if isActive {
                print("⏰ Timer triggered: refreshing screen time data.")
                historyManager.loadFromFirestore {
                    historyManager.refreshDailyTrackingArraysIfNeeded()
                    historyManager.saveToFirestore()
                    triggerAnimation()
                }
            } else {
                print("🛑 Timer skipped: ScreenTimeView not visible.")
            }
        }
    }

    private func triggerAnimation() {
        DispatchQueue.main.async {
            if !didAnimateInitialBar {
                animatedProgress = 0.0
                withAnimation(.easeInOut(duration: 2.0)) {
                    animatedProgress = progress
                }
                didAnimateInitialBar = true
            } else {
                withAnimation(.easeInOut(duration: 2.0)) {
                    animatedProgress = progress
                }
            }
        }
    }

    private func updateOverlayState() {
        let hasAvailableMilestone = appState.stepMilestones.contains(1)
                               || appState.calorieMilestones.contains(1)
                               || appState.flightsMilestones.contains(1)

        let hasRemainingMilestones = appState.stepMilestones.contains(0)
                                || appState.calorieMilestones.contains(0)
                                || appState.flightsMilestones.contains(0)

        let newState = !hasAvailableMilestone && hasRemainingMilestones
        withAnimation(.easeInOut(duration: 0.4)) {
            showOverlay = newState
        }
    }

    private func markMilestonesUsed() {
        // Convert any "1" entries to "2" for used milestones
        let usedSteps = appState.stepMilestones.map { $0 == 1 ? 2 : $0 }
        let usedCalories = appState.calorieMilestones.map { $0 == 1 ? 2 : $0 }
        let usedFlights = appState.flightsMilestones.map { $0 == 1 ? 2 : $0 }

        // Update AppState immediately
        appState.stepMilestones = usedSteps
        appState.calorieMilestones = usedCalories
        appState.flightsMilestones = usedFlights

        // Persist to Firestore
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([
            "stepGoalArray": usedSteps,
            "calorieGoalArray": usedCalories,
            "flightsGoalArray": usedFlights
        ]) { error in
            if let error = error {
                print("❌ Failed to mark milestones used: \(error.localizedDescription)")
            } else {
                print("✅ Milestones marked used and saved to Firestore.")
                updateOverlayState()
            }
        }
    }
}

// AppUsageView: reusable component for displaying individual app usage (not currently used).
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

// ProgressBarView: reusable horizontal progress bar with rounded corners.
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
                    .animation(.easeInOut(duration: 2.0), value: progress)
            }
            .cornerRadius(geometry.size.height / 2)
        }
    }
}

// PreviewProvider for rendering ScreenTimeView in Xcode canvas.
struct ScreenTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenTimeView()
            .environmentObject(ThemeManager())
            .environmentObject(GoalManager())
            .environmentObject(AppState())
    }
}
