// MainTabView.swift: Root tab bar view providing navigation between core app sections with custom theming and haptics.
import UIKit
import SwiftUI

// MainTabView displays the Fitness, Screen Time, Progress, and Profile tabs and handles tab selection.
struct MainTabView: View {
    // ViewModel for user profile data passed into the Profile tab.
    let profileViewModel: ProfileViewModel
    // Environment objects for app-wide theme settings and authentication/app state.
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    // Tracks the currently selected tab index for haptic feedback and accent coloring.
    @State private var selectedTab: Int = 0

    // The view body builds the TabView with four tabs and applies theming and haptics.
    var body: some View {
        // TabView binds to selectedTab to switch between child views.
        TabView(selection: $selectedTab) {
            FitnessView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Fitness")
                }
                .tag(0)

            ScreenTimeView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Screen Time")
                }
                .tag(1)

            ProgressView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Progress")
                }
                .tag(2)

            ProfileView(viewModel: profileViewModel)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        // Haptic feedback when the user switches tabs.
        .onChange(of: selectedTab) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        // Compute and apply a blended accent color based on the current theme gradient.
        .accentColor(
            Color(
                red: (themeManager.accentColor.components.red + themeManager.accentColor2.components.red) / 2,
                green: (themeManager.accentColor.components.green + themeManager.accentColor2.components.green) / 2,
                blue: (themeManager.accentColor.components.blue + themeManager.accentColor2.components.blue) / 2
            )
        )
        // Configure the tab bar appearance (blur, background color) and fetch profile data on launch.
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)
            appearance.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            profileViewModel.fetchUserData(appState: appState, themeManager: themeManager)
        }
    }
}

// PreviewProvider for rendering MainTabView in Xcode canvas.
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(profileViewModel: ProfileViewModel())
            .environmentObject(ThemeManager())
            .environmentObject(GoalManager())
    }
}

// Extension to extract RGB components from a SwiftUI Color for dynamic color blending.
extension Color {
    var components: (red: Double, green: Double, blue: Double) {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        return (Double(r), Double(g), Double(b))
    }
}
