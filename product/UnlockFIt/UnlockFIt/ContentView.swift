import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainTabView()
                    .onAppear {
                        print("Navigated to MainTabView")
                    }
            } else {
                NavigationView {
                    LoginView()
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
