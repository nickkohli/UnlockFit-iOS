import SwiftUI

struct MainTabView: View {
    let profileViewModel: ProfileViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        TabView {
            FitnessView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Fitness")
                }

            ScreenTimeView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Screen Time")
                }

            ProgressView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Progress")
                }

            ProfileView(viewModel: profileViewModel)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .accentColor(themeManager.accentColor) // Selected tab icon color
        .onAppear {
            profileViewModel.fetchUserData()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(profileViewModel: ProfileViewModel())
            .environmentObject(ThemeManager())
            .environmentObject(GoalManager()) 
    }
}
