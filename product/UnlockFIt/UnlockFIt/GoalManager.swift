import Foundation
import HealthKit
import Combine

class GoalManager: ObservableObject {
    @Published var stepsToday: Int = 0
    @Published var caloriesBurned: Double = 0
    @Published var minutesExercised: Double = 0

    private var healthKitManager = APIModule.shared

    func updateGoalsFromHealthKit() {
        healthKitManager.getStepsToday { [weak self] steps in
            DispatchQueue.main.async {
                self?.stepsToday = Int(steps)
            }
        }

        healthKitManager.getCaloriesBurnedToday { [weak self] calories in
            DispatchQueue.main.async {
                self?.caloriesBurned = calories
            }
        }

        healthKitManager.getExerciseMinutesToday { [weak self] minutes in
            DispatchQueue.main.async {
                self?.minutesExercised = minutes
            }
        }
    }
}
