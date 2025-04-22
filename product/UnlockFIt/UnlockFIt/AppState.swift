import SwiftUI

class AppState: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    @Published var stepGoal: Int = 10000 // Default step goal, user-adjustable
    @Published var calorieGoal: Int = 500 // Default calorie goal, user-adjustable
    @Published var flightsClimbedGoal: Int = 10 // Default flights climbed goal, user-adjustable
    
    @Published var stepMilestones: [Int] = [0, 0, 0, 0]
    @Published var calorieMilestones: [Int] = [0, 0, 0, 0]
    @Published var flightsMilestones: [Int] = [0, 0, 0, 0]
}
