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
}
