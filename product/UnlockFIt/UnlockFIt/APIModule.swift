import Foundation
import HealthKit

// APIModule is a singleton responsible for interfacing with HealthKit.
// It handles authorisation and querying of health data (steps, calories, flights).
class APIModule {
    static let shared = APIModule()
    let healthStore = HKHealthStore()
    
    private init() {}

    // Request read-only access to step count, active energy, and flights climbed from HealthKit.
    // Calls completion(true) if authorisation succeeds.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("❌ HealthKit Authorization Error: \(error.localizedDescription)")
            }
            completion(success)
        }
    }
    
    // Alternative authorisation method: checks availability then requests HealthKit permissions.
    func requestHealthKitAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }
    
    // Fetch the total number of steps for today, from midnight until now.
    func fetchTodayStepCount(completion: @escaping (Double) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0.0)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: .count()))
        }
        
        healthStore.execute(query)
    }
    
    // Fetch the total active calories burned today.
    func fetchTodayCalories(completion: @escaping (Double) -> Void) {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0.0)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: .kilocalorie()))
        }
        
        healthStore.execute(query)
    }
    
    // Fetch the total number of flights of stairs climbed today.
    func fetchTodayFlightsClimbed(completion: @escaping (Double) -> Void) {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(0.0)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: flightsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: .count()))
        }
        
        healthStore.execute(query)
    }
    
    // Convenience wrappers for today's health metrics using the fetch... methods.
    func getStepsToday(completion: @escaping (Double) -> Void) {
        fetchTodayStepCount(completion: completion)
    }

    func getCaloriesBurnedToday(completion: @escaping (Double) -> Void) {
        fetchTodayCalories(completion: completion)
    }
    
    func getFlightsClimbedToday(completion: @escaping (Double) -> Void) {
        fetchTodayFlightsClimbed(completion: completion)
    }

    // Fetch cumulative health data between two dates (used for weekly summaries).
    func getSteps(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        fetchSumQuantity(for: stepType, unit: HKUnit.count(), from: startDate, to: endDate, completion: completion)
    }

    func getCalories(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        fetchSumQuantity(for: calorieType, unit: HKUnit.kilocalorie(), from: startDate, to: endDate, completion: completion)
    }
    
    func getFlightsClimbed(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        fetchSumQuantity(for: flightsType, unit: HKUnit.count(), from: startDate, to: endDate, completion: completion)
    }

    // Internal helper: run an HKStatisticsQuery to sum samples of a given quantity type over a date range.
    private func fetchSumQuantity(for type: HKQuantityType, unit: HKUnit, from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var total = 0.0
            if let quantity = result?.sumQuantity() {
                total = quantity.doubleValue(for: unit)
            }
            DispatchQueue.main.async {
                completion(total)
            }
        }
        healthStore.execute(query)
    }
}
