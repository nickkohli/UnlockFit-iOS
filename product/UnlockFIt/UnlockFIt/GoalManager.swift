import Foundation
import HealthKit
import Combine

class GoalManager: ObservableObject {
    @Published var stepsToday: Double = 0
    @Published var caloriesBurned: Double = 0
    @Published var minutesExercised: Double = 0

    private var healthKitManager = APIModule.shared

    init() {
        healthKitManager.requestAuthorization { [weak self] success in
            if success {
                print("✅ HealthKit authorization granted")
                self?.updateGoalsFromHealthKit()
            } else {
                print("❌ HealthKit authorization denied or failed")
            }
        }
    }

    func updateGoalsFromHealthKit() {
        healthKitManager.getStepsToday { [weak self] steps in
            DispatchQueue.main.async {
                print("🔢 Steps Today: \(steps)")
                self?.stepsToday = steps
            }
        }

        healthKitManager.getCaloriesBurnedToday { [weak self] calories in
            DispatchQueue.main.async {
                print("🔥 Calories Burned Today: \(calories)")
                self?.caloriesBurned = calories
            }
        }

        healthKitManager.getExerciseMinutesToday { [weak self] minutes in
            DispatchQueue.main.async {
                print("⏱️ Minutes Exercised Today: \(minutes)")
                self?.minutesExercised = minutes
            }
        }
    }
}
