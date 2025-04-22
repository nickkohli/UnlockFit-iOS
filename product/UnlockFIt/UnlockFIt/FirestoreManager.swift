import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}

    func saveNewUser(uid: String, email: String, nickname: String, completion: ((Error?) -> Void)? = nil) {
        let userData: [String: Any] = [
            "email": email,
            "nickname": nickname,
            "stepGoal": 10000,
            "calorieGoal": 500,
            "flightsClimbedGoal": 10,
            "theme": "Default",
            "screenTimeSeconds": [0, 0, 0, 0, 0, 0, 0],
            "screenTimeSessions": [0, 0, 0, 0, 0, 0, 0],
            "profileImageURL": "https://firebasestorage.googleapis.com/v0/b/unlockfit-956fc.firebasestorage.app/o/profile_images%2Fdeafult.jpg?alt=media&token=8b2ed802-8c39-44cd-9cd8-8072f7f91bab",
            "stepGoalArray": [0, 0, 0, 0],
            "calorieGoalArray": [0, 0, 0, 0],
            "flightsGoalArray": [0, 0, 0, 0],
            "sessionUnlockedToday": false,
            "lastGoalReset": Date().formatted(.iso8601)
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("❌ Failed to save user data: \(error.localizedDescription)")
            } else {
                print("✅ User data successfully saved to Firestore!")
            }
            completion?(error)
        }
    }
    
    func fetchUserData(uid: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        db.collection("users").document(uid).getDocument { documentSnapshot, error in
            if let error = error {
                print("❌ Failed to fetch user data: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let document = documentSnapshot, document.exists,
                  let data = document.data() else {
                print("⚠️ No user data found for UID: \(uid)")
                completion(nil, nil)
                return
            }
            
            print("✅ User data fetched: \(data)")
            completion(data, nil)
        }
    }
    
    func saveUserGoals(uid: String, stepGoal: Int, calorieGoal: Int, flightsClimbedGoal: Int) {
        let goals: [String: Any] = [
            "stepGoal": stepGoal,
            "calorieGoal": calorieGoal,
            "flightsClimbedGoal": flightsClimbedGoal
        ]
        
        Firestore.firestore().collection("users").document(uid).updateData(goals) { error in
            if let error = error {
                print("❌ Failed to save user goals: \(error.localizedDescription)")
            } else {
                print("✅ User goals updated successfully in Firestore!")
            }
        }
    }
    
    func updateUserTheme(uid: String, theme: String) {
        Firestore.firestore().collection("users").document(uid).updateData([
            "theme": theme
        ]) { error in
            if let error = error {
                print("❌ Failed to update theme: \(error.localizedDescription)")
            } else {
                print("🎨 Theme successfully updated to '\(theme)'")
            }
        }
    }

    func saveMilestoneState(uid: String, stepArray: [Int], calorieArray: [Int], flightsArray: [Int], sessionUnlocked: Bool) {
        let milestoneData: [String: Any] = [
            "stepGoalArray": stepArray,
            "calorieGoalArray": calorieArray,
            "flightsGoalArray": flightsArray,
            "sessionUnlockedToday": sessionUnlocked
        ]
        
        db.collection("users").document(uid).updateData(milestoneData) { error in
            if let error = error {
                print("❌ Failed to save milestone state: \(error.localizedDescription)")
            } else {
                print("✅ Milestone state updated successfully in Firestore!")
            }
        }
    }
}
