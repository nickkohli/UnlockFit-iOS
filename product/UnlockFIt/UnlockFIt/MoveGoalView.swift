// MoveGoalView.swift: UI for editing step, calorie, and flights-climbed goals with animated confirmation and confetti.
import SwiftUI
import FirebaseAuth
import UIKit
import ConfettiSwiftUI

// MoveGoalView allows the user to adjust their daily fitness goals and saves them to Firestore with feedback.

struct MoveGoalView: View {
    // Environment objects for applying app theme and storing global app state including user goals.
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState

    // Local state for the goal values before they are saved to global AppState and Firestore.
    @State private var stepGoal: Int = 10000
    @State private var calorieGoal: Int = 500
    @State private var flightsClimbedGoal: Int = 30

    // Local UI state for showing success, triggering confetti, disabling the save button, and animating the button gradient.
    @State private var showSuccessMessage = false
    @State private var confettiCounter = 0
    @State private var isButtonDisabled = false
    @State private var animationProgress: CGFloat = 1.0

    // The view body lays out the sliders, save button, and handles animations and confetti on goal update.
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                // Header text prompting the user to update their fitness goals.
                Text("Update Your Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Slider control for adjusting the Step goal with a gradient fill.
                goalSlider(title: "Step Goal 🚶‍♂️", value: $stepGoal, range: 1000...30000, gradient: LinearGradient(
                    gradient: Gradient(colors: [CustomColors.ringRed, CustomColors.ringRed2]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))

                // Slider control for adjusting the Calorie goal with a gradient fill.
                goalSlider(title: "Calorie Goal 🔥", value: $calorieGoal, range: 100...2000, gradient: LinearGradient(
                    gradient: Gradient(colors: [CustomColors.ringGreen, CustomColors.ringGreen2]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))

                // Slider control for adjusting the Flights Climbed goal with a gradient fill.
                goalSlider(title: "Flights Climbed Goal 🪜", value: $flightsClimbedGoal, range: 1...30, gradient: LinearGradient(
                    gradient: Gradient(colors: [CustomColors.ringBlue, CustomColors.ringBlue2]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))

                // Save Changes button: writes new goals to AppState and Firestore, then shows haptic, animation, and confetti.
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
                // Display a temporary success message after goals are saved.
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

    // Helper function that builds a slider with a colored gradient bar and numeric label for a given goal.
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
                        case "Step Goal 🚶‍♂️":
                            step = 500
                        case "Calorie Goal 🔥":
                            step = 50
                        case "Flights Climbed Goal 🪜":
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

// PreviewProvider for rendering MoveGoalView in Xcode canvas.
struct MoveGoalView_Previews: PreviewProvider {
    static var previews: some View {
        MoveGoalView()
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())
    }
}
