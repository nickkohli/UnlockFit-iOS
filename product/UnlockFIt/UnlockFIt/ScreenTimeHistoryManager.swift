// ScreenTimeHistoryManager.swift: Manages logging, persisting, and retrieving screen-time session history for the past 7 days.
import Foundation
// Import Firestore for cloud-based data storage.
import FirebaseFirestore
// Import FirebaseAuth to identify the current user’s UID.
import FirebaseAuth

// ScreenTimeSession represents a single screen-time session with an ID, start date, and duration.
struct ScreenTimeSession: Codable, Identifiable {
    var id: UUID
    let date: Date
    let duration: TimeInterval
}

// ScreenTimeHistoryManager publishes the user’s screen-time seconds and session counts and syncs with Firestore.
class ScreenTimeHistoryManager: ObservableObject {
    // Published arrays track daily totals for seconds and session counts, plus the date of the last recorded session.
    @Published var screenTimeSeconds: [Int] = Array(repeating: 0, count: 7)
    @Published var screenTimeSessions: [Int] = Array(repeating: 0, count: 7)
    @Published var lastSessionDate: Date = Date()

    // On init, reset arrays for a new day if needed and load persisted history from Firestore.
    init() {
        refreshForNewDay()
        loadFromFirestore()
    }
    
    // Return today’s total screen time in seconds.
    func getTodayScreenTime() -> TimeInterval {
        return TimeInterval(screenTimeSeconds.first ?? 0)
    }

    // Return the number of screen-time sessions completed today.
    func getTodaySessionCount() -> Int {
        return screenTimeSessions.first ?? 0
    }

    // Add a new session: shift arrays if a new day started, update today’s counters, and save to Firestore.
    func addSession(duration: TimeInterval) {
        refreshForNewDay()
        lastSessionDate = Date()
        screenTimeSeconds[0] += Int(duration)
        screenTimeSessions[0] += 1
        saveToFirestore()
    }
    
    // Public trigger to refresh arrays when crossing midnight.
    func refreshDailyTrackingArraysIfNeeded() {
        refreshForNewDay()
    }

    // Public API to reload history from Firestore.
    func loadScreenTimeHistory() {
        loadFromFirestore()
    }

    // Public API to persist history arrays to Firestore.
    func saveScreenTimeHistory() {
        saveToFirestore()
    }

    // Reset all tracking arrays and last session date to start fresh.
    func resetScreenTimeData() {
        screenTimeSeconds = Array(repeating: 0, count: 7)
        screenTimeSessions = Array(repeating: 0, count: 7)
        lastSessionDate = Date()
    }

    // Internal: detect days passed since last session and shift arrays, filling with zeros for new days.
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

    // Write the current screen-time arrays and lastSession timestamp to the user’s Firestore document.
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

    // Read screen-time arrays and lastSession from Firestore and update published properties.
    func loadFromFirestore(completion: (() -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            // On successful fetch, update local arrays and lastSessionDate from Firestore fields.
            if let data = snapshot?.data() {
                self.screenTimeSeconds = data["screenTimeSeconds"] as? [Int] ?? Array(repeating: 0, count: 7)
                self.screenTimeSessions = data["screenTimeSessions"] as? [Int] ?? Array(repeating: 0, count: 7)
                if let timestamp = data["lastSession"] as? Timestamp {
                    self.lastSessionDate = timestamp.dateValue()
                }
                print("✅ Loaded screen time from Firestore")
            }
            // Log any errors encountered while loading from Firestore.
            else if let error = error {
                print("❌ Error loading screen time: \(error.localizedDescription)")
            }
            completion?()
        }
    }
}
