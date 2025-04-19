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
            "minuteGoal": 30,
            "theme": "Default"
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
    
    func saveUserGoals(uid: String, stepGoal: Int, calorieGoal: Int, minuteGoal: Int) {
        let goals: [String: Any] = [
            "stepGoal": stepGoal,
            "calorieGoal": calorieGoal,
            "minuteGoal": minuteGoal
        ]
        
        Firestore.firestore().collection("users").document(uid).updateData(goals) { error in
            if let error = error {
                print("❌ Failed to save user goals: \(error.localizedDescription)")
            } else {
                print("✅ User goals updated successfully in Firestore!")
            }
        }
    }
}
