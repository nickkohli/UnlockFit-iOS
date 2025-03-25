import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false // Tracks whether the user is logged in
    @Published var stepGoal: Int = 10000 // Default step goal, user-adjustable
    @Published var calorieGoal: Int = 500 // Default calorie goal, user-adjustable
    @Published var minuteGoal: Int = 30 // Default active minutes goal, user-adjustable
}
