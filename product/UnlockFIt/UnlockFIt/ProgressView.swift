import UIKit
import SwiftUI

// Metric selection for trend graph
enum TrendType: String, CaseIterable, Identifiable {
    case steps = "Steps"
    case calories = "Calories"
    case flights = "Flights"
    var id: Self { self }
}

struct ProgressView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var goalManager: GoalManager
    @EnvironmentObject var appState: AppState
    @State private var lastRefreshDate = Date()
    @State private var refreshTimer: Timer? = nil
    @State private var isSpinning = false
    @State private var isActive: Bool = true
    @State private var selectedTrend: TrendType = .steps
    @State private var hasAppearedOnce = false
    @State private var summaryRefreshTrigger: Int = 0

    // Compute best fitness day index and metrics
    private var bestDaySummary: (dayName: String, steps: Int, calories: Int, flights: Int) {
        let steps = goalManager.weeklySteps
        let calories = goalManager.weeklyCalories
        let flights = goalManager.weeklyFlightsClimbed

        // find maxima for normalization (avoid divide-by-zero)
        let maxSteps = steps.max().flatMap { $0 > 0 ? $0 : nil } ?? 1
        let maxCalories = calories.max().flatMap { $0 > 0 ? $0 : nil } ?? 1
        let maxFlights = flights.max().flatMap { $0 > 0 ? $0 : nil } ?? 1

        // compute combined normalized score per day
        let combinedScores: [Double] = zip(zip(steps, calories), flights).map { (sc, f) in
            let (s, c) = sc
            let sNorm = Double(s) / Double(maxSteps)
            let cNorm = c / Double(maxCalories)
            let fNorm = Double(f) / Double(maxFlights)
            return (sNorm + cNorm + fNorm) / 3.0
        }

        // pick index of highest combined score (default to today)
        let bestIndex = combinedScores.enumerated().max(by: { $0.element < $1.element })?.offset ?? (steps.count - 1)

        // compute the date corresponding to that index
        let offset = bestIndex - (steps.count - 1)
        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!

        // format day name, showing "Today" if appropriate
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayName: String
        if Calendar.current.isDateInToday(date) {
            dayName = "Today"
        } else {
            dayName = formatter.string(from: date)
        }

        // return the raw metrics for that best day
        return (dayName: dayName,
                steps: Int(steps[bestIndex]),
                calories: Int(calories[bestIndex]),
                flights: Int(flights[bestIndex]))
    }

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
                            summaryRefreshTrigger += 1
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
                        Text("Weekly Overview 🔍")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
                            ProgressCard(title: "Steps", value: NumberFormatter.localizedString(from: NSNumber(value: Int(goalManager.weeklySteps.reduce(0, +))), number: .decimal), color: CustomColors.ringRed)
                            ProgressCard(title: "Calories", value: NumberFormatter.localizedString(from: NSNumber(value: Int(goalManager.weeklyCalories.reduce(0, +))), number: .decimal), color: CustomColors.ringGreen)
                            ProgressCard(title: "Flights", value: NumberFormatter.localizedString(from: NSNumber(value: Int(goalManager.weeklyFlightsClimbed.reduce(0, +))), number: .decimal), color: CustomColors.ringBlue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                    // Fitness Trends
                    VStack(alignment: .leading) {
                        Text("Fitness Trends 📈")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                            .frame(height: 21)
                        
                        // Metric selector
                        Picker("Metric", selection: $selectedTrend) {
                            ForEach(TrendType.allCases) { metric in
                                Text(metric.rawValue).tag(metric)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom, 8)
                        .environment(\.colorScheme, .dark)
                        .tint(.white)
                        .onChange(of: selectedTrend) {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }

                        Spacer()
                            .frame(height: 20)

                        MultiLineGraph(
                            trend: selectedTrend,
                            stepData: goalManager.weeklySteps,
                            calorieData: goalManager.weeklyCalories,
                            flightsClimbedData: goalManager.weeklyFlightsClimbed
                        )
                        .frame(height: 200)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    // Best day summary card
                    let summary = bestDaySummary
                    Text("🏆 Your best day so far is \(summary.dayName), where you've hit \(summary.steps) steps, burned \(summary.calories) calories, and climbed \(summary.flights) flights! Keep going, you’re crushing it! 💪")
                        .id(summaryRefreshTrigger)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding()
                .onAppear {
                    print("\n")
                    print("🔄 ProgressView appeared")
                    isActive = true
                    if !hasAppearedOnce {
                        hasAppearedOnce = true
                        print("🔁 First appearance: refreshing weekly data.")
                        goalManager.refreshWeeklyData()
                    }
                    if refreshTimer == nil {
                        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                            if isActive {
                                print("⏰ ProgressView timer: refreshing weekly data.")
                                goalManager.refreshWeeklyData()
                                lastRefreshDate = Date()
                                summaryRefreshTrigger += 1
                            } else {
                                print("🛑 ProgressView timer skipped – view not visible.")
                            }
                        }
                    } else {
                        print("⚠️ ProgressView timer already running.")
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
    let trend: TrendType
    let stepData: [Double]
    let calorieData: [Double]
    let flightsClimbedData: [Double]
    @State private var graphProgress: CGFloat = 0.0

    // Provide the selected data series and its color
    private var chartData: (data: [Double], color: Color) {
        switch trend {
        case .steps:
            return (stepData, CustomColors.ringRed)
        case .calories:
            return (calorieData, CustomColors.ringGreen)
        case .flights:
            return (flightsClimbedData, CustomColors.ringBlue)
        }
    }

    var body: some View {
        let data = chartData.data
        let lineColor = chartData.color
        let maxValue = data.max() ?? 0
        let midValue = maxValue / 2

        return VStack {
            HStack(alignment: .top) {
                // Y-Axis labels
                VStack {
                    Text(String(format: "%.0f", maxValue))
                        .font(.caption)
                    Spacer()
                    Text(String(format: "%.0f", midValue))
                        .font(.caption)
                    Spacer()
                    Text("0")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .frame(width: 30)

                // Chart area
                GeometryReader { geometry in
                    ZStack {
                        // Draw grid lines
                        Path { path in
                            let height = geometry.size.height
                            // horizontal at mid
                            path.move(to: CGPoint(x: 0, y: height / 2))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: height / 2))
                        }
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        
                        LinePath(data: data, color: lineColor, progress: graphProgress, geometry: geometry)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.5)) {
                            graphProgress = 1.0
                        }
                    }
                }
            }
            .frame(height: 200)

            // X-Axis day labels
            HStack {
                let labels = generateDayLabels(count: data.count)
                ForEach(labels, id: \.self) { label in
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .offset(x: 17)
        }
    }

    // Helper to generate day labels with single-letter weekdays and "TDY" for today
    private func generateDayLabels(count: Int) -> [String] {
        let calendar = Calendar.current
        // Single-letter abbreviations: Sunday through Saturday
        let weekdayLetters = ["S", "M", "T", "W", "T", "F", "S"]
        return (0..<count).map { index in
            let offset = count - 1 - index
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else {
                return ""
            }
            if calendar.isDateInToday(date) {
                return "TDY"
            } else {
                let weekdayIndex = calendar.component(.weekday, from: date) - 1
                return weekdayLetters[weekdayIndex]
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

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environmentObject(ThemeManager())
            .environmentObject(GoalManager())
            .environmentObject(AppState())
    }
}
