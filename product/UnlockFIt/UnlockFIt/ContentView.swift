import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var profileViewModel = ProfileViewModel()

    var body: some View {
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
