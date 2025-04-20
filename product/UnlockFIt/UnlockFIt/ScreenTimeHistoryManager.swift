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
    @Published var lastSessionDate: Date = Date()

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
        lastSessionDate = Date()
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

    func resetScreenTimeData() {
        screenTimeSeconds = Array(repeating: 0, count: 7)
        screenTimeSessions = Array(repeating: 0, count: 7)
        lastSessionDate = Date()
    }

    private func refreshForNewDay() {
        let calendar = Calendar.current
        let now = Date()
        let daysPassed = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastSessionDate), to: calendar.startOfDay(for: now)).day ?? 0

        if daysPassed > 0 {
            for _ in 0..<daysPassed {
                screenTimeSeconds.insert(0, at: 0)
                screenTimeSessions.insert(0, at: 0)
            }
            if screenTimeSeconds.count > 7 { screenTimeSeconds = Array(screenTimeSeconds.prefix(7)) }
            if screenTimeSessions.count > 7 { screenTimeSessions = Array(screenTimeSessions.prefix(7)) }
            lastSessionDate = now
        }
    }

    func saveToFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let lastSessionTimestamp = Timestamp(date: lastSessionDate)
        db.collection("users").document(uid).updateData([
            "screenTimeSeconds": screenTimeSeconds,
            "screenTimeSessions": screenTimeSessions,
            "lastSession": lastSessionTimestamp
        ]) { error in
            if let error = error {
                print("❌ Error saving screen time: \(error.localizedDescription)")
            } else {
                print("✅ Screen time saved to Firestore successfully.")
            }
        }
    }

    func loadFromFirestore(completion: (() -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.screenTimeSeconds = data["screenTimeSeconds"] as? [Int] ?? Array(repeating: 0, count: 7)
                self.screenTimeSessions = data["screenTimeSessions"] as? [Int] ?? Array(repeating: 0, count: 7)
                if let timestamp = data["lastSession"] as? Timestamp {
                    self.lastSessionDate = timestamp.dateValue()
                }
                print("✅ Loaded screen time from Firestore")
            } else if let error = error {
                print("❌ Error loading screen time: \(error.localizedDescription)")
            }
            completion?()
        }
    }
}
