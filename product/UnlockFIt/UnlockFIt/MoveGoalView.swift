import SwiftUI

struct MoveGoalView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState

    @State private var stepGoal: Int = 10000
    @State private var calorieGoal: Int = 500
    @State private var minuteGoal: Int = 30

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("Update Your Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                goalSlider(title: "Step Goal", value: $stepGoal, range: 1000...30000, gradient: LinearGradient(
                    gradient: Gradient(colors: [CustomColors.ringRed, CustomColors.ringRed2]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))

                goalSlider(title: "Calorie Goal", value: $calorieGoal, range: 100...2000, gradient: LinearGradient(
                    gradient: Gradient(colors: [CustomColors.ringGreen, CustomColors.ringGreen2]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))

                goalSlider(title: "Minute Goal", value: $minuteGoal, range: 10...180, gradient: LinearGradient(
                    gradient: Gradient(colors: [CustomColors.ringBlue, CustomColors.ringBlue2]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))

                Spacer()

                Button(action: {
                    appState.stepGoal = stepGoal
                    appState.calorieGoal = calorieGoal
                    appState.minuteGoal = minuteGoal
                }) {
                    Text("Save Changes")
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
            .onAppear {
                stepGoal = appState.stepGoal
                calorieGoal = appState.calorieGoal
                minuteGoal = appState.minuteGoal
            }
        }
    }

    func goalSlider(title: String, value: Binding<Int>, range: ClosedRange<Int>, gradient: LinearGradient) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Text("\(value.wrappedValue)")
                    .foregroundColor(.white)
            }

            ZStack(alignment: .leading) {
                GeometryReader { geometry in
                    gradient
                        .frame(width: CGFloat(value.wrappedValue - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound) * geometry.size.width, height: 4)
                        .cornerRadius(2)
                        .offset(y: 14)
                }

                Slider(value: Binding(
                    get: { Double(value.wrappedValue) },
                    set: { value.wrappedValue = Int($0) }
                ), in: Double(range.lowerBound)...Double(range.upperBound))
                .accentColor(.clear)
            }
            .frame(height: 30)
        }
    }
}

struct MoveGoalView_Previews: PreviewProvider {
    static var previews: some View {
        MoveGoalView()
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager()) 
    }
}
