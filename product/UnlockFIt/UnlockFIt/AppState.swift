import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false // Tracks whether the user is logged in
}
