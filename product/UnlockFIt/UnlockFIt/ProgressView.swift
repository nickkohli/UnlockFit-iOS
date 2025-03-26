import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var themeManager: ThemeManager // Inject ThemeManager
    @EnvironmentObject var goalManager: GoalManager

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Progress")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Weekly Overview
                    VStack(alignment: .leading) {
                        Text("Weekly Overview")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
                            ProgressCard(title: "Steps", value: "\(goalManager.stepsToday)", color: CustomColors.ringRed)
                            ProgressCard(title: "Calories", value: "\(Int(goalManager.caloriesBurned))", color: CustomColors.ringGreen)
                            ProgressCard(title: "Minutes", value: "\(Int(goalManager.minutesExercised))", color: CustomColors.ringBlue)
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
                        LineGraph(data: [50, 70, 90, 85, 95, 100, 110], color: themeManager.accentColor) // Animated graph
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
            }
        }
    }
}

// Reusable Progress Card
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
        .background(Color(red: 0.108, green: 0.108, blue: 0.114)) // Dark background
        .cornerRadius(10) // Rounded corners
    }
}

// Placeholder Line Graph with Animation
struct LineGraph: View {
    let data: [Double]
    let color: Color

    @State private var graphProgress: CGFloat = 0.0 // For animating the graph

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(data.count - 1)
                let maxValue = data.max() ?? 1

                path.move(to: CGPoint(x: 0, y: height - CGFloat(data[0]) / CGFloat(maxValue) * height))

                for index in 1..<data.count {
                    let x = CGFloat(index) * step
                    let y = height - CGFloat(data[index]) / CGFloat(maxValue) * height
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .trim(from: 0.0, to: graphProgress) // Draw progressively
            .stroke(color, lineWidth: 2)
            .animation(.easeInOut(duration: 2.5), value: graphProgress) // Smooth animation
        }
        .onAppear {
            graphProgress = 1.0 // Animate graph on appear
        }
    }
}

// Reusable Achievement Badge with Single Jump Animation
struct AchievementBadge: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let shadowColor: Color

    @State private var scale: CGFloat = 1.0 // For jump animation

    var body: some View {
        VStack {
            ZStack {
                // Outer glow effect
                Circle()
                    .fill(gradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: shadowColor.opacity(0.45), radius: 7.5, x: 0, y: 5)
                // Inner Circle for 3D effect
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.4), .clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 70, height: 70)
                    .blendMode(.overlay)

                // Badge Icon
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .scaleEffect(scale) // Apply scale animation
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 0.5) // One jump animation
                ) {
                    scale = 1.1 // Slightly grow
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        scale = 1.0 // Return to normal size
                    }
                }
            }

            // Badge Title
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
            .environmentObject(ThemeManager()) // Inject ThemeManager for preview
            .environmentObject(GoalManager())
    }
}
