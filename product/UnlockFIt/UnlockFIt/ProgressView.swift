import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var goalManager: GoalManager
    @EnvironmentObject var appState: AppState
    @State private var lastRefreshDate = Date()
    @State private var refreshTimer: Timer? = nil
    @State private var isSpinning = false
    @State private var isActive: Bool = true

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Your Progress")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            isSpinning = true
                            goalManager.refreshWeeklyData()
                            lastRefreshDate = Date()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                isSpinning = false
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .rotationEffect(.degrees(isSpinning ? 360 : 0))
                                .animation(isSpinning ? .easeInOut(duration: 1.0) : .default, value: isSpinning)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }

                    // Weekly Overview
                    VStack(alignment: .leading) {
                        Text("Weekly Overview")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
                            ProgressCard(title: "Steps", value: NumberFormatter.localizedString(from: NSNumber(value: Int(goalManager.weeklySteps.reduce(0, +))), number: .decimal), color: CustomColors.ringRed)
                            ProgressCard(title: "Calories", value: NumberFormatter.localizedString(from: NSNumber(value: Int(goalManager.weeklyCalories.reduce(0, +))), number: .decimal), color: CustomColors.ringGreen)
                            ProgressCard(title: "Minutes", value: NumberFormatter.localizedString(from: NSNumber(value: Int(goalManager.weeklyMinutes.reduce(0, +))), number: .decimal), color: CustomColors.ringBlue)
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
                        MultiLineGraph(
                            stepData: goalManager.weeklySteps,
                            calorieData: goalManager.weeklyCalories,
                            minuteData: goalManager.weeklyMinutes
                        )
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

                        HStack(spacing: 20) {
                            AchievementBadge(
                                title: "10k Steps",
                                icon: "figure.walk",
                                gradient: LinearGradient(
                                    gradient: Gradient(colors: [CustomColors.bronze, CustomColors.bronze2]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                shadowColor: CustomColors.bronze
                            )
                            AchievementBadge(
                                title: "Screen Saver",
                                icon: "clock",
                                gradient: LinearGradient(
                                    gradient: Gradient(colors: [CustomColors.silver, CustomColors.silver2]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                shadowColor: CustomColors.silver
                            )
                            AchievementBadge(
                                title: "Calorie Burner",
                                icon: "flame",
                                gradient: LinearGradient(
                                    gradient: Gradient(colors: [CustomColors.gold, CustomColors.gold2]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                shadowColor: CustomColors.gold
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding()
                .onAppear {
                    isActive = true
                    goalManager.refreshWeeklyData()
                    refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                        if isActive {
                            print("⏰ ProgressView timer: refreshing weekly data.")
                            goalManager.refreshWeeklyData()
                            lastRefreshDate = Date()
                        } else {
                            print("🛑 ProgressView timer skipped – view not visible.")
                        }
                    }
                }
                .onDisappear {
                    print("👋 Left ProgressView – stopping timer.")
                    isActive = false
                    refreshTimer?.invalidate()
                    refreshTimer = nil
                }
            }
        }
    }
}

// MultiLineGraph to display multiple data series
struct MultiLineGraph: View {
    let stepData: [Double]
    let calorieData: [Double]
    let minuteData: [Double]
    @State private var graphProgress: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinePath(data: stepData, color: CustomColors.ringRed, progress: graphProgress, geometry: geometry)
                LinePath(data: calorieData, color: CustomColors.ringGreen, progress: graphProgress, geometry: geometry)
                LinePath(data: minuteData, color: CustomColors.ringBlue, progress: graphProgress, geometry: geometry)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5)) {
                    graphProgress = 1.0
                }
            }
        }
    }
}

struct LinePath: View {
    let data: [Double]
    let color: Color
    let progress: CGFloat
    let geometry: GeometryProxy

    var body: some View {
        Path { path in
            guard let max = data.max(), max > 0 else { return }
            let step = geometry.size.width / CGFloat(data.count - 1)
            let height = geometry.size.height

            path.move(to: CGPoint(x: 0, y: height - CGFloat(data[0] / max) * height))

            for i in 1..<data.count {
                let x = CGFloat(i) * step
                let y = height - CGFloat(data[i] / max) * height
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        .trim(from: 0.0, to: progress)
        .stroke(color, lineWidth: 2)
    }
}

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
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.all, 12.0)
        .background(Color(red: 0.108, green: 0.108, blue: 0.114))
        .cornerRadius(10)
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let shadowColor: Color

    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: shadowColor.opacity(0.45), radius: 7.5, x: 0, y: 5)

                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.4), .clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 70, height: 70)
                    .blendMode(.overlay)

                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .scaleEffect(scale)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.5)) {
                    scale = 1.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        scale = 1.0
                    }
                }
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 5)
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environmentObject(ThemeManager())
            .environmentObject(GoalManager())
            .environmentObject(AppState())
    }
}
