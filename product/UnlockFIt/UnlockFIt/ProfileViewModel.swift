import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var nickname = ""
    @Published var email = ""
    @Published var profileImage: UIImage? = nil

    func fetchUserData(appState: AppState? = nil, themeManager: ThemeManager? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { [weak self] document, error in
            if let data = document?.data() {
                DispatchQueue.main.async {
                    self?.nickname = data["nickname"] as? String ?? "No Name"
                    self?.email = data["email"] as? String ?? "No Email"

                    if let urlString = data["profileImageURL"] as? String,
                       let url = URL(string: urlString) {
                        URLSession.shared.dataTask(with: url) { data, _, _ in
                            if let data = data {
                                DispatchQueue.main.async {
                                    self?.profileImage = UIImage(data: data)
                                }
                            }
                        }.resume()
                    }

                    // 🔄 Sync app state + theme
                    if let appState = appState {
                        appState.stepGoal = data["stepGoal"] as? Int ?? appState.stepGoal
                        appState.calorieGoal = data["calorieGoal"] as? Int ?? appState.calorieGoal
                        appState.minuteGoal = data["minuteGoal"] as? Int ?? appState.minuteGoal
                    }

                    if let theme = data["theme"] as? String {
                        themeManager?.selectedTheme = theme
                    }
                }
            }
        }
    }
}
