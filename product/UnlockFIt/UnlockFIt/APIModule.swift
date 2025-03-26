import Foundation
import HealthKit

class APIModule {
    static let shared = APIModule()
    let healthStore = HKHealthStore()
    
    private init() {}
    
    // MARK: - HealthKit Authorisation
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("❌ HealthKit Authorization Error: \(error.localizedDescription)")
            }
            completion(success)
        }
    }
    
    // Request HealthKit authorization
    func requestHealthKitAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }
    
    // Fetch today's step count
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
    
    // Fetch today's calories burned
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
    
    // Fetch today's exercise minutes
    func fetchTodayExerciseMinutes(completion: @escaping (Double) -> Void) {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(0.0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: .minute()))
        }

        healthStore.execute(query)
    }
    
    func getStepsToday(completion: @escaping (Double) -> Void) {
        fetchTodayStepCount(completion: completion)
    }

    func getCaloriesBurnedToday(completion: @escaping (Double) -> Void) {
        fetchTodayCalories(completion: completion)
    }

    func getExerciseMinutesToday(completion: @escaping (Double) -> Void) {
        fetchTodayExerciseMinutes(completion: completion)
    }

    func getSteps(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        fetchSumQuantity(for: stepType, unit: HKUnit.count(), from: startDate, to: endDate, completion: completion)
    }

    func getCalories(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        fetchSumQuantity(for: calorieType, unit: HKUnit.kilocalorie(), from: startDate, to: endDate, completion: completion)
    }

    func getMinutes(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        fetchSumQuantity(for: exerciseType, unit: HKUnit.minute(), from: startDate, to: endDate, completion: completion)
    }

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
