import Foundation
import HealthKit
import Combine

// GoalManager handles fetching and publishing HealthKit fitness data (steps, calories, flights) for today and the past week.
class GoalManager: ObservableObject {
    // Today's live step count fetched from HealthKit.
    @Published var stepsToday: Double = 0
    // Today's total active calories burned from HealthKit.
    @Published var caloriesBurned: Double = 0
    // Today's total flights of stairs climbed from HealthKit.
    @Published var flightsClimbed: Double = 0

    // Array of step counts for each of the last 7 days.
    @Published var weeklySteps: [Double] = Array(repeating: 0.0, count: 7)
    // Array of calories burned for each of the last 7 days.
    @Published var weeklyCalories: [Double] = Array(repeating: 0.0, count: 7)
    // Array of flights climbed for each of the last 7 days.
    @Published var weeklyFlightsClimbed: [Double] = Array(repeating: 0.0, count: 7)

    // Tracks whether HealthKit permissions are missing or denied.
    @Published var isHealthPermissionMissing: Bool = false

    private var healthKitManager = APIModule.shared

    // On init, request HealthKit authorisation and load initial data or mark permissions missing.
    init() {
        healthKitManager.requestAuthorization { [weak self] success in
            if success {
                print("✅ HealthKit authorization granted")
                self?.verifyHealthPermissions()
                self?.updateGoalsFromHealthKit(completion: {})
                self?.fetchWeeklyData()
            } else {
                print("❌ HealthKit authorization denied or failed")
                self?.isHealthPermissionMissing = true
            }
        }
    }

    // Fetch today's metrics concurrently (steps, calories, flights) then call completion.
    func updateGoalsFromHealthKit(completion: @escaping () -> Void) {
        let group = DispatchGroup()

        group.enter()
        healthKitManager.getStepsToday { [weak self] steps in
            DispatchQueue.main.async {
                print("🔢 Steps Today: \(steps)")
                self?.stepsToday = steps
                group.leave()
            }
        }

        group.enter()
        healthKitManager.getCaloriesBurnedToday { [weak self] calories in
            DispatchQueue.main.async {
                print("🔥 Calories Burned Today: \(calories)")
                self?.caloriesBurned = calories
                group.leave()
            }
        }

        group.enter()
        healthKitManager.getFlightsClimbedToday { [weak self] flights in
            DispatchQueue.main.async {
                print("🧗‍♂️ Flights Climbed Today: \(flights)")
                self?.flightsClimbed = flights
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    // Retrieve and aggregate health data for the past 7 days into weekly arrays.
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

    // Manually refresh today's and weekly health data, e.g., on pull-to-refresh or timer.
    func refreshWeeklyData(completion: (() -> Void)? = nil) {
        print("🔄 Refreshing weekly data manually or on timer...")
        updateGoalsFromHealthKit {
            self.fetchWeeklyData()
            completion?()
        }
    }
    
    // Check if HealthKit read permissions are still granted; update isHealthPermissionMissing.
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
