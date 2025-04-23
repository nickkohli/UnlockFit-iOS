// ProfileViewModel.swift: Manages loading and publishing user profile data (nickname, email, image) from Firebase.
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

// ProfileViewModel fetches and stores the user’s nickname, email, and profile image for SwiftUI views.
class ProfileViewModel: ObservableObject {
    // The user’s display name, loaded from Firestore.
    @Published var nickname = ""
    // The user’s email address, loaded from Firestore.
    @Published var email = ""
    // The user’s profile photo, downloaded from Firebase Storage.
    @Published var profileImage: UIImage? = nil
    
    // Fetch just the nickname field from the user’s Firestore document.
    func fetchNickname(completion: @escaping (String?) -> Void) {
        // Ensure we have a logged‑in user UID before reading Firestore.
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ fetchNickname failed: no UID found.")
            completion(nil)
            return
        }

        // Reference the Firestore document for the current user.
        let docRef = Firestore.firestore().collection("users").document(uid)
        // Log and propagate any Firestore read errors.
        docRef.getDocument { document, error in
            // Log and propagate any Firestore read errors.
            if let error = error {
                print("❌ fetchNickname Firestore error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // On success, update the published nickname on the main thread.
            if let data = document?.data(),
               let nickname = data["nickname"] as? String {
                print("✅ fetchNickname success: \(nickname)")
                DispatchQueue.main.async {
                    self.nickname = nickname
                }
                completion(nickname)
            } else {
                print("⚠️ fetchNickname: nickname not found in document.")
                completion(nil)
            }
        }
    }
    
    // Fetch full user data (nickname, email, image URL, goals, theme) and apply to view model and optional app state.
    func fetchUserData(appState: AppState? = nil, themeManager: ThemeManager? = nil) {
        // Bail out if no authenticated user is found.
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { [weak self] document, error in
            if let data = document?.data() {
                // Update all published properties and sync AppState/theme on the main thread.
                DispatchQueue.main.async {
                    self?.nickname = data["nickname"] as? String ?? "No Name"
                    self?.email = data["email"] as? String ?? "No Email"

                    // If a profileImageURL exists, download the image data asynchronously.
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

                    // Apply stored goals from Firestore to the global AppState.
                    if let appState = appState {
                        appState.stepGoal = data["stepGoal"] as? Int ?? appState.stepGoal
                        appState.calorieGoal = data["calorieGoal"] as? Int ?? appState.calorieGoal
                        appState.flightsClimbedGoal = data["flightsClimbedGoal"] as? Int ?? appState.flightsClimbedGoal
                    }

                    // Apply stored theme selection to the ThemeManager.
                    if let theme = data["theme"] as? String {
                        themeManager?.selectedTheme = theme
                    }
                }
            }
        }
    }
}
