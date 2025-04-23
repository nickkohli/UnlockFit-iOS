import SwiftUI

// ContentView determines whether to show the login flow or the main app tabs based on authentication state.
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var profileViewModel = ProfileViewModel()

    // Switch between LoginView and MainTabView when `appState.isLoggedIn` changes.
    var body: some View {
        // Group wrapper to handle conditional view display.
        Group {
            if appState.isLoggedIn {
                MainTabView(profileViewModel: profileViewModel)
                    .onAppear {
                        print("Navigated to MainTabView")
                    }
            } else {
                NavigationView {
                    LoginView(profileViewModel: profileViewModel)
                        .onAppear {
                            print("Showing LoginView")
                        }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        // Debug print current login state whenever ContentView appears.
        .onAppear {
            print("ContentView appeared. Current isLoggedIn: \(appState.isLoggedIn)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(GoalManager())
    }
}
