import Foundation

struct ScreenTimeSession: Codable, Identifiable {
    var id: UUID
    let date: Date
    let duration: TimeInterval // in seconds
}

class ScreenTimeHistoryManager: ObservableObject {
    @Published var sessionHistory: [ScreenTimeSession] = []

    init() {
        loadSessions()
    }

    func addSession(duration: TimeInterval) {
        let session = ScreenTimeSession(id: UUID(), date: Date(), duration: duration)
        sessionHistory.append(session)
        saveSessions()
    }

    func totalTimeToday() -> TimeInterval {
        let calendar = Calendar.current
        return sessionHistory
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.duration }
    }

    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessionHistory) {
            UserDefaults.standard.set(data, forKey: "ScreenTimeHistory")
            print("💾 Saved sessionHistory: \(sessionHistory.map(\.duration))")
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "ScreenTimeHistory"),
           let sessions = try? JSONDecoder().decode([ScreenTimeSession].self, from: data) {
            sessionHistory = sessions
        }
    }
}
