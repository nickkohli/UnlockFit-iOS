import Foundation
import FirebaseFirestore

// FirestoreManager handles all reads/writes to Firebase Firestore for user data.
class FirestoreManager {
    // Singleton instance for global access to Firestore operations.
    static let shared = FirestoreManager()
    // Reference to the Firestore database.
    private let db = Firestore.firestore()
    
    // Private initializer to enforce singleton pattern.
    private init() {}

    // Create a new user document with initial profile, goals, and history arrays.
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
            "stepGoalArray": [0, 0, 0, 0],
            "calorieGoalArray": [0, 0, 0, 0],
            "flightsGoalArray": [0, 0, 0, 0],
            "profileImageURL": "https://firebasestorage.googleapis.com/v0/b/unlockfit-956fc.firebasestorage.app/o/profile_images%2Fdeafult.jpg?alt=media&token=8b2ed802-8c39-44cd-9cd8-8072f7f91bab"
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
    
    // Retrieve the user’s document data from Firestore by UID.
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
    
    // Update only the user’s fitness goal values in their Firestore document.
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
    
    // Update the user’s selected theme string in Firestore.
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
}
