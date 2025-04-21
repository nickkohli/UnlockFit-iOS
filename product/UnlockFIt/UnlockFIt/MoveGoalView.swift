import SwiftUI
import FirebaseAuth
import UIKit
import ConfettiSwiftUI

struct MoveGoalView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState

    @State private var stepGoal: Int = 10000
    @State private var calorieGoal: Int = 500
    @State private var flightsClimbedGoal: Int = 30

    @State private var showSuccessMessage = false
    @State private var confettiCounter = 0
    @State private var isButtonDisabled = false
    @State private var animationProgress: CGFloat = 1.0

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

                    goalSlider(title: "Flights Climbed Goal", value: $flightsClimbedGoal, range: 1...30, gradient: LinearGradient(
                    gradient: Gradient(colors: [CustomColors.ringBlue, CustomColors.ringBlue2]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))

                if showSuccessMessage {
                    Text("Goals updated successfully!")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()

                Button(action: {
                    appState.stepGoal = stepGoal
                    appState.calorieGoal = calorieGoal
                    appState.flightsClimbedGoal = flightsClimbedGoal

                    if let uid = Auth.auth().currentUser?.uid {
                        FirestoreManager.shared.saveUserGoals(
                            uid: uid,
                            stepGoal: stepGoal,
                            calorieGoal: calorieGoal,
                            flightsClimbedGoal: flightsClimbedGoal
                        )
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        isButtonDisabled = true
                        animationProgress = 0.0
                        withAnimation(.linear(duration: 3)) {
                            animationProgress = 1.0
                        }
                        withAnimation {
                            showSuccessMessage = true
                            confettiCounter += 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isButtonDisabled = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showSuccessMessage = false
                            }
                        }
                    }
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            GeometryReader { geometry in
                                LinearGradient(
                                    gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor2]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .opacity(0.4 + 0.7 * animationProgress)
                                .clipped()
                            }
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isButtonDisabled)
            }
            .padding()
                .onAppear {
                    stepGoal = appState.stepGoal
                    calorieGoal = appState.calorieGoal
                    flightsClimbedGoal = appState.flightsClimbedGoal
                }
            .confettiCannon(trigger: $confettiCounter, repetitions: 1, repetitionInterval: 0.5)
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
                    set: {
                        let newValue = Int($0)
                        let step: Int
                        switch title {
                        case "Step Goal":
                            step = 500
                        case "Calorie Goal":
                            step = 50
                        case "Flights Climbed Goal":
                            step = 1
                        default:
                            step = 1
                        }
                        value.wrappedValue = max(range.lowerBound, min(range.upperBound, (newValue / step) * step))
                    }
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
