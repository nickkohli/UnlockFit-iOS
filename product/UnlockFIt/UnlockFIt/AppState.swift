import SwiftUI

class AppState: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    @Published var stepGoal: Int = 10000
    @Published var calorieGoal: Int = 500
    @Published var flightsClimbedGoal: Int = 10
    
    @Published var stepMilestones: [Int] = [0, 0, 0, 0]
    @Published var calorieMilestones: [Int] = [0, 0, 0, 0]
    @Published var flightsMilestones: [Int] = [0, 0, 0, 0]
}
