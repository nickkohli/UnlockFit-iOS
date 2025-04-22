import Foundation
import HealthKit
import Combine
import FirebaseAuth

class GoalManager: ObservableObject {
    @Published var stepsToday: Double = 0
    @Published var caloriesBurned: Double = 0
    @Published var flightsClimbed: Double = 0

    @Published var weeklySteps: [Double] = Array(repeating: 0.0, count: 7)
    @Published var weeklyCalories: [Double] = Array(repeating: 0.0, count: 7)
    @Published var weeklyFlightsClimbed: [Double] = Array(repeating: 0.0, count: 7)

    @Published var isHealthPermissionMissing: Bool = false

    // New Published properties for milestone tracking
    @Published var stepGoalArray: [Int] = [0, 0, 0, 0]
    @Published var calorieGoalArray: [Int] = [0, 0, 0, 0]
    @Published var flightsGoalArray: [Int] = [0, 0, 0, 0]
    @Published var sessionUnlockedToday: Bool = false

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
                self?.evaluateFitnessMilestones()
            }
        }

        healthKitManager.getCaloriesBurnedToday { [weak self] calories in
            DispatchQueue.main.async {
                print("🔥 Calories Burned Today: \(calories)")
                self?.caloriesBurned = calories
                self?.evaluateFitnessMilestones()
            }
        }

        healthKitManager.getFlightsClimbedToday { [weak self] flights in
            DispatchQueue.main.async {
                print("🧗‍♂️ Flights Climbed Today: \(flights)")
                self?.flightsClimbed = flights
                self?.evaluateFitnessMilestones()
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
    // MARK: - Fitness Milestone Evaluation
    func evaluateFitnessMilestones() {
        guard !sessionUnlockedToday else { return }

        let milestones: [Double] = [0.25, 0.5, 0.75, 1.0]

        // Retrieve user goals (these should come from user settings or Firestore ideally)
        let stepGoal = 10000.0
        let calorieGoal = 500.0
        let flightsGoal = 10.0

        let stepProgress = stepsToday / stepGoal
        let calorieProgress = caloriesBurned / calorieGoal
        let flightsProgress = flightsClimbed / flightsGoal

        var updated = false

        for (i, threshold) in milestones.enumerated() {
            if stepGoalArray[i] == 0, stepProgress >= threshold, stepProgress < (i < 3 ? milestones[i + 1] : Double.infinity) {
                stepGoalArray[i] = 1
                updated = true
                break
            }
            if calorieGoalArray[i] == 0, calorieProgress >= threshold, calorieProgress < (i < 3 ? milestones[i + 1] : Double.infinity) {
                calorieGoalArray[i] = 1
                updated = true
                break
            }
            if flightsGoalArray[i] == 0, flightsProgress >= threshold, flightsProgress < (i < 3 ? milestones[i + 1] : Double.infinity) {
                flightsGoalArray[i] = 1
                updated = true
                break
            }
        }

        if updated {
            print("🎯 Milestone reached! Unlocking one session.")
            sessionUnlockedToday = true
            if let uid = Auth.auth().currentUser?.uid {
                FirestoreManager.shared.saveMilestoneState(
                    uid: uid,
                    stepArray: self.stepGoalArray,
                    calorieArray: self.calorieGoalArray,
                    flightsArray: self.flightsGoalArray,
                    sessionUnlocked: self.sessionUnlockedToday
                )
            } else {
                print("❌ Could not persist milestone state – no user UID found.")
            }
        }

        if stepProgress >= 1.0, calorieProgress >= 1.0, flightsProgress >= 1.0 {
            print("🏆 All goals completed — unlimited sessions unlocked.")
            sessionUnlockedToday = true
            if let uid = Auth.auth().currentUser?.uid {
                FirestoreManager.shared.saveMilestoneState(
                    uid: uid,
                    stepArray: self.stepGoalArray,
                    calorieArray: self.calorieGoalArray,
                    flightsArray: self.flightsGoalArray,
                    sessionUnlocked: self.sessionUnlockedToday
                )
            } else {
                print("❌ Could not persist milestone state – no user UID found.")
            }
        }
    }
    
    struct MilestoneHint {
        let metric: String
        let percentage: Double
    }

    var closestMilestone: MilestoneHint? {
        let stepMilestone = stepGoalArray.firstIndex(of: 0).map { MilestoneHint(metric: "steps", percentage: [25, 50, 75, 100][$0]) }
        let calorieMilestone = calorieGoalArray.firstIndex(of: 0).map { MilestoneHint(metric: "calories", percentage: [25, 50, 75, 100][$0]) }
        let flightsMilestone = flightsGoalArray.firstIndex(of: 0).map { MilestoneHint(metric: "flights climbed", percentage: [25, 50, 75, 100][$0]) }

        return [stepMilestone, calorieMilestone, flightsMilestone]
            .compactMap { $0 }
            .sorted(by: { $0.percentage < $1.percentage })
            .first
    }
}
