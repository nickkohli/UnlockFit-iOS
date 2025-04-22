import Foundation
import HealthKit
import Combine

class GoalManager: ObservableObject {
    @Published var stepsToday: Double = 0
    @Published var caloriesBurned: Double = 0
    @Published var flightsClimbed: Double = 0

    @Published var weeklySteps: [Double] = Array(repeating: 0.0, count: 7)
    @Published var weeklyCalories: [Double] = Array(repeating: 0.0, count: 7)
    @Published var weeklyFlightsClimbed: [Double] = Array(repeating: 0.0, count: 7)

    @Published var isHealthPermissionMissing: Bool = false

    private var healthKitManager = APIModule.shared

    init() {
        healthKitManager.requestAuthorization { [weak self] success in
            if success {
                print("✅ HealthKit authorization granted")
                self?.verifyHealthPermissions()
                self?.updateGoalsFromHealthKit()
                self?.fetchWeeklyData()
            } else {
                print("❌ HealthKit authorization denied or failed")
                self?.isHealthPermissionMissing = true
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

        healthKitManager.getFlightsClimbedToday { [weak self] flights in
            DispatchQueue.main.async {
                print("🧗‍♂️ Flights Climbed Today: \(flights)")
                self?.flightsClimbed = flights
            }
        }
    }

    func fetchWeeklyData() {
        let calendar = Calendar.current
        let now = Date()

        var steps: [Double] = Array(repeating: 0.0, count: 7)
        var calories: [Double] = Array(repeating: 0.0, count: 7)
        var flights: [Double] = Array(repeating: 0.0, count: 7)

        let dispatchGroup = DispatchGroup()

        for i in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            let start = calendar.startOfDay(for: day)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!

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
            healthKitManager.getFlightsClimbed(from: start, to: end) { value in
                flights[6 - i] = value
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("📆 Weekly Steps: \(steps)")
            print("📆 Weekly Calories: \(calories)")
            print("🧗‍♂️ Weekly Flights Climbed: \(flights)")
            self.weeklySteps = steps
            self.weeklyCalories = calories
            self.weeklyFlightsClimbed = flights
        }
    }

    func refreshWeeklyData() {
        print("🔄 Refreshing weekly data manually or on timer...")
        updateGoalsFromHealthKit()
        fetchWeeklyData()
    }
    private func verifyHealthPermissions() {
        let healthStore = HKHealthStore()

        let requiredTypes: [HKObjectType?] = [
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)
        ]

        let readTypes = requiredTypes.compactMap { $0 }

        healthStore.getRequestStatusForAuthorization(toShare: [], read: Set(readTypes)) { [weak self] status, _ in
            DispatchQueue.main.async {
                if status != .unnecessary {
                    print("⚠️ Missing one or more Health permissions.")
                    self?.isHealthPermissionMissing = true
                } else {
                    self?.isHealthPermissionMissing = false
                }
            }
        }
    }
}
