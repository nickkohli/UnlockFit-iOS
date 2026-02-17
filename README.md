# UnlockFit

## Project Overview
UnlockFit is a gamified wellness application that links physical activity with controlled screen time access. Users complete personalised fitness goals (steps, active calories, and flights climbed) to earn timed screen sessions, reinforcing disciplined digital habits through measurable physical progress.

The app integrates HealthKit for real-time fitness tracking and Firebase Firestore for synchronised user data across devices. Every goal update, milestone unlock, and screen session is written to Firestore and reflected instantly via snapshot listeners, ensuring consistent cross-device state.

Progress is visualised through concentric activity rings, milestone indicators, and seven-day screen time logs. Offline caching prevents data loss, scheduled midnight resets maintain daily integrity, and customisable themes and profile settings allow users to tailor their experience while maintaining a structured behavioural feedback loop.

---

## Key Features
- **Authentication & Registration:** Secure login and registration flows with inline validation, initial Firestore user document creation, and illustrated notification setup.
- **Real-Time Fitness Challenges:** Complete step, calorie, and flight goals to earn app sessions; progress rings driven by HealthKit and synchronised via Firestore.
- **Custom Goal-Setting:** Create personalised fitness challenges with adjustable targets.
- **Dynamic Themes:** Multiple UI themes—Default, Neon, Ulku, Performance, Slate, Aurora, Cyberpunk—for a tailored look.
- **Screen Time Management:** Track and limit app usage with Firestore-backed session arrays and lock overlays when limits are reached.
- **Dynamic Island Live Activity:** Live countdown ring for active sessions displayed in the Dynamic Island and on the Lock Screen.
- **Data Visualisation:** Weekly trend graphs, best-day highlights, and detailed insights based on historical HealthKit and screen time data.
- **Offline Persistence:** Automatic queueing and synchronisation of Firestore updates when connectivity is restored.
- **Daily Reset Routine:** Scheduled reset of daily aggregates, milestones, and screen time arrays at midnight.

---

## Technology Stack
- **Swift and SwiftUI:** For seamless UI development and declarative design.
- **HealthKit API:** Integrated to track fitness metrics like steps, active energy, and flights climbed.
- **Firebase Firestore:** Real-time synchronisation, offline caching, and snapshot listeners for user data.
- **Git:** Version control and collaborative development workflow.
- **Screen Time API:** Not used due to platform limitations; screen time logic is implemented using internal session tracking and Firestore.

---

## Repository Structure
```
    /
    ├── README.md                                       # Overview of the project, setup instructions, and documentation
    ├── diary.md                                        # Project diary tracking progress, updates, and notes
    └── product/                                        # Core project files for UnlockFIt application
        └── UnlockFIt/                                  # Main Xcode project for UnlockFIt
            ├── Info.plist                              # Configuration file defining app metadata and permissions
            ├── UnlockFIt/                              # Source code folder for the UnlockFIt app
            │   ├── AppState.swift                      # Defines global application state management
            │   ├── MainTabView.swift                   # Implements main tab-based navigation UI
            │   ├── InstructionView.swift               # UI for user instructions and guidance
            │   ├── ScreenTimeSessionManager.swift      # Manages screen time session logic
            │   ├── APIModule.swift                     # Handles network requests to backend services
            │   ├── PrivacyView.swift                   # UI for privacy settings and information
            │   ├── HealthPermissionView.swift          # Requests and displays health data permissions
            │   ├── UnlockFIt.entitlements              # Defines app’s entitlements and capabilities
            │   ├── ProfileView.swift                   # UI for user profile display and editing
            │   ├── ScreenTimeHistoryManager.swift      # Manages retrieval and storage of past sessions
            │   ├── ProgressView.swift                  # UI showing user progress and statistics
            │   ├── LoginView.swift                     # UI for user authentication screens
            │   ├── ScreenTimeLiveActivity.swift        # Live Activity configuration for screen time
            │   ├── ScreenTimeView.swift                # UI for current session screen time tracking
            │   ├── MoveGoalView.swift                  # UI for setting and displaying move goals
            │   ├── CustomColors.swift                  # Defines custom colour palette used in UI
            │   ├── ViewModifiers.swift                 # Reusable SwiftUI view modifiers
            │   ├── GoogleService-Info.template.plist   # Template Firebase configuration file (replace with your own)
            │   ├── ThemeManager.swift                  # Handles dynamic theming across the app
            │   ├── WelcomeView.swift                   # UI shown on first launch or after logout
            │   ├── ScreenTimeActivityAttributes.swift  # Attributes for Live Activity widget
            │   ├── ThemesView.swift                    # UI for selecting and previewing themes
            │   ├── NotificationSetupView.swift         # UI for notification permission and scheduling
            │   ├── FitnessView.swift                   # UI for fitness-related data and metrics
            │   ├── RegisterView.swift                  # UI for new user registration flow
            │   ├── GoalManager.swift                   # Business logic for managing user goals
            │   ├── FirestoreManager.swift              # Handles CRUD operations with Firestore database
            │   ├── ContentView.swift                   # Entry point SwiftUI view for the app
            │   ├── ProfileViewModel.swift              # ViewModel for profile data binding and logic
            │   ├── UnlockFItApp.swift                  # App entry point and lifecycle configuration
            │   ├── Assets.xcassets/                    # Asset catalog containing images and colour sets
            │   │   ├── Contents.json                   # Metadata for asset catalog
            │   │   ├── notif_delivery.imageset/        # Images for notification delivery screen
            │   │   │   ├── notif_delivery.jpg
            │   │   │   ├── Contents.json
            │   │   │   └── notif_delivery 1.jpg
            │   │   ├── AppIcon.appiconset/             # App icon image set in multiple resolutions
            │   │   │   ├── 120 3.png
            │   │   │   ├── …                           # Additional icon resolution files
            │   │   │   └── Contents.json
            │   │   ├── AccentColor.colorset/           # Accent colour definition for UI theming
            │   │   │   └── Contents.json
            │   │   ├── notif_banner.imageset/          # Images for notification banner previews
            │   │   │   ├── notif_banner.jpg
            │   │   │   └── Contents.json
            │   │   ├── health_perms.imageset/          # Images illustrating health permission prompts
            │   │   │   ├── health_perms.jpg
            │   │   │   └── Contents.json
            │   │   └── notif_toggle.imageset/          # Images for notification toggle UI
            │   │       ├── notif_toggle.jpg
            │   │       └── Contents.json
            │   └── Preview Content/                    # Xcode preview support assets
            │       └── Preview Assets.xcassets/
            │           └── Contents.json
            ├── UnlockFIt.xcodeproj/                    # Xcode project settings and workspace data
            │   ├── project.pbxproj                     # Project configuration and file references
            │   ├── project.xcworkspace/                # Workspace data for Xcode
            │   │   ├── contents.xcworkspacedata
            │   │   |
            │   │   └── xcshareddata/                   # Shared workspace data (SwiftPM, schemes)
            │   │       └── swiftpm/
            │   │           └── Package.resolved
            │   ├── xcshareddata/                       # Shared project data (schemes)
            │   │   └── xcschemes/
            │   │       ├── UnlockFIt.xcscheme
            │   │       └── UnlockFItWidgetExtension.xcscheme
            │   |
            ├── UnlockFItTests/                         # Unit test target for core app logic
            │   └── UnlockFItTests.swift                # Test cases for UnlockFIt modules
            ├── UnlockFItUITests/                       # UI test target for app interface
            │   ├── UnlockFItUITests.swift              # UI test definitions
            │   └── UnlockFItUITestsLaunchTests.swift   # Launch performance tests
            └── UnlockFItWidget/                        # Widget extension target for Live Activities
                ├── UnlockFItWidgetBundle.swift         # Widget bundle definition
                ├── AppIntent.swift                     # Intent definitions for widget interactions
                ├── UnlockFItWidget.swift               # Main widget view implementation
                ├── UnlockFItWidgetLiveActivity.swift   # Live Activity configuration
                ├── UnlockFItWidgetControl.swift        # Widget configuration and controls
                ├── Info.plist                          # Widget-specific configuration file
                └── Assets.xcassets/                    # Asset catalog for widget
                    ├── Contents.json                   # Metadata for widget assets
                    ├── WidgetBackground.colorset/
                    │   └── Contents.json
                    ├── AppIcon.appiconset/
                    │   └── Contents.json
                    └── AccentColor.colorset/
                        └── Contents.json
```

---

## Firestore Architecture
- **users (collection)**: Each document is keyed by the user’s UID and stores:
  - `nickname`, `email`, `theme`, and `profileImageURL`
  - `stepGoal`, `calorieGoal`, `flightsGoal`
  - `stepGoalArray`, `calorieGoalArray`, `flightsGoalArray` (milestone tracking: 0 = unmet, 1 = unlocked, 2 = used)
  - `screenTimeSeconds`, `screenTimeSessions` (arrays indexed for 7-day tracking)
- **Realtime Listeners:** Sync user data, theme, fitness progress, and screen time sessions live across devices.
- **Offline Persistence:** Enables queued writes and automatic sync when connection is restored.

---

## Current Progress
- **Authentication & Registration:** Implemented login, registration forms, Firestore user initialisation, and notification setup.
- **Core UI & Navigation:** Built main tabs (Fitness, Screen Time, Progress, Profile) with SwiftUI.
- **Firestore Integration:** Snapshot listeners and writes for real-time updates of goals, milestones, and sessions.
- **Fitness Tab:** Three concentric progress rings linked to HealthKit and Firestore, milestone tracking with animated dots.
- **Screen Time Tab:** Seven-day bar chart, session management, lock overlays, and Firestore-backed arrays.
- **Progress Tab:** Multi-line weekly trends, best-day computation, and real-time UI updates.
- **Profile Tab:** Settings bound to Firestore fields, theme selection, privacy info, and logout.
- **Custom Features:** Custom goal-setting and enhanced data visualisation.
- **Offline Support & Daily Reset:** Offline persistence and scheduled midnight resets.

---

## Upcoming Milestones
- **Screen Time API Integration:** Explore deeper integration with Apple Screen Time APIs as platform capabilities evolve.
- **Community Features:** Explore options for shared challenges and leaderboards.
- **App Packaging:** Prepare the project for distribution as a testable package to facilitate further development and beta testing.
- **App Store Release:** Complete App Store submission requirements including App Store assets, compliance checks, and final testing for public release.

---

## Setup (Firebase)

This project uses Firebase for authentication and real-time data synchronisation.

1. Create a Firebase project in the Firebase Console.
2. Add an iOS app to the project.
3. Download your `GoogleService-Info.plist`.
4. Place the file in:
   `product/UnlockFIt/UnlockFIt/`
5. Build and run the project in Xcode.

A template file is included in the repository:
`GoogleService-Info.template.plist`

---

## How to Run
1. Clone this repository:
   ```bash
   git clone https://github.com/nickkohli/UnlockFit-iOS.git
   ```
2. Open `product/UnlockFIt/UnlockFIt/UnlockFIt.xcodeproj` in Xcode.
3. Select your target device or simulator.
4. Build and run the project.
5. Ensure HealthKit permissions are enabled in your device’s Settings for full functionality.
6. Xcode 15+ is recommended. For full HealthKit functionality, run on a physical iPhone device.

---

## Screenshots / Demo Link
*Coming soon.*

---

## Contributing
Contributions are welcome! If you'd like to contribute to UnlockFit, please fork the repository and create a pull request with your proposed changes.

---

## Contact
**Developer:** Nick Kohli  
For questions or collaboration, feel free to connect via GitHub or LinkedIn.
