import SwiftUI

// AppState holds global application state and user preferences.
// It persists login status and publishes fitness goals & milestones.
class AppState: ObservableObject {
    // Persist and observe whether the user is currently logged in.
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    // Auto-defined daily fitness goals:
    @Published var stepGoal: Int = 10000
    @Published var calorieGoal: Int = 500
    @Published var flightsClimbedGoal: Int = 10
    
    // Milestone thresholds for unlocking screen time sessions (four levels each).
    @Published var stepMilestones: [Int] = [0, 0, 0, 0]
    @Published var calorieMilestones: [Int] = [0, 0, 0, 0]
    @Published var flightsMilestones: [Int] = [0, 0, 0, 0]
}
