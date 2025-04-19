import Foundation
import FirebaseFirestore
import FirebaseAuth

struct ScreenTimeSession: Codable, Identifiable {
    var id: UUID
    let date: Date
    let duration: TimeInterval // in seconds
}

class ScreenTimeHistoryManager: ObservableObject {
    @Published var screenTimeSeconds: [Int] = Array(repeating: 0, count: 7)
    @Published var screenTimeSessions: [Int] = Array(repeating: 0, count: 7)
    private var lastUpdated: Date = Date()

    init() {
        refreshForNewDay()
        loadFromFirestore()
    }
    
    func getTodayScreenTime() -> TimeInterval {
        return TimeInterval(screenTimeSeconds.first ?? 0)
    }

    func getTodaySessionCount() -> Int {
        return screenTimeSessions.first ?? 0
    }

    func addSession(duration: TimeInterval) {
        refreshForNewDay()
        screenTimeSeconds[0] += Int(duration)
        screenTimeSessions[0] += 1
        saveToFirestore()
    }
    
    func refreshDailyTrackingArraysIfNeeded() {
        refreshForNewDay()
    }

    func loadScreenTimeHistory() {
        loadFromFirestore()
    }

    func saveScreenTimeHistory() {
        saveToFirestore()
    }

    private func refreshForNewDay() {
        let calendar = Calendar.current
        let now = Date()
        if !calendar.isDate(now, inSameDayAs: lastUpdated) {
            screenTimeSeconds.insert(0, at: 0)
            screenTimeSessions.insert(0, at: 0)
            if screenTimeSeconds.count > 7 { screenTimeSeconds.removeLast() }
            if screenTimeSessions.count > 7 { screenTimeSessions.removeLast() }
            lastUpdated = now
        }
    }

    private func saveToFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([
            "screenTimeSeconds": screenTimeSeconds,
            "screenTimeSessions": screenTimeSessions
        ]) { error in
            if let error = error {
                print("❌ Error saving screen time: \(error.localizedDescription)")
            } else {
                print("✅ Screen time saved successfully.")
            }
        }
    }

    private func loadFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.screenTimeSeconds = data["screenTimeSeconds"] as? [Int] ?? Array(repeating: 0, count: 7)
                self.screenTimeSessions = data["screenTimeSessions"] as? [Int] ?? Array(repeating: 0, count: 7)
            } else if let error = error {
                print("❌ Error loading screen time: \(error.localizedDescription)")
            }
        }
    }
}
