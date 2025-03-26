import Foundation
import HealthKit
import Combine

class GoalManager: ObservableObject {
    @Published var stepsToday: Double = 0
    @Published var caloriesBurned: Double = 0
    @Published var minutesExercised: Double = 0

    @Published var weeklySteps: [Double] = Array(repeating: 0.0, count: 7)
    @Published var weeklyCalories: [Double] = Array(repeating: 0.0, count: 7)
    @Published var weeklyMinutes: [Double] = Array(repeating: 0.0, count: 7)

    private var healthKitManager = APIModule.shared

    init() {
        healthKitManager.requestAuthorization { [weak self] success in
            if success {
                print("✅ HealthKit authorization granted")
                self?.updateGoalsFromHealthKit()
                self?.fetchWeeklyData()
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

    func fetchWeeklyData() {
        let calendar = Calendar.current
        let now = Date()

        var steps: [Double] = Array(repeating: 0.0, count: 7)
        var calories: [Double] = Array(repeating: 0.0, count: 7)
        var minutes: [Double] = Array(repeating: 0.0, count: 7)

        let dispatchGroup = DispatchGroup()

        for i in 0..<7 {
            guard let start = calendar.date(byAdding: .day, value: -i, to: now),
                  let end = calendar.date(byAdding: .day, value: -i + 1, to: now) else {
                continue
            }

            dispatchGroup.enter()
            healthKitManager.getSteps(from: start, to: end) { value in
                steps[6 - i] = value
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            healthKitManager.getCalories(from: start, to: end) { value in
                calories[6 - i] = value
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            healthKitManager.getMinutes(from: start, to: end) { value in
                minutes[6 - i] = value
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("📆 Weekly Steps: \(steps)")
            print("📆 Weekly Calories: \(calories)")
            print("📆 Weekly Minutes: \(minutes)")
            self.weeklySteps = steps
            self.weeklyCalories = calories
            self.weeklyMinutes = minutes
        }
    }
}
