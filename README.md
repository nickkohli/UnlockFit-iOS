# UnlockFit

## Project Overview
UnlockFit is a gamified mobile application that integrates fitness goals with screen time management. The app encourages healthier habits by requiring users to complete fitness challenges, such as step goals or calorie burns, to unlock selected apps. By combining these two critical aspects of modern lifestyles, UnlockFit aims to promote both physical well-being and digital balance.

---

## Key Features
- **Fitness Challenges:** Users complete fitness goals (e.g., steps, calories) to unlock apps.
- **Screen Time Management:** Leverages Apple's Screen Time API for app restriction.
- **Dynamic Themes:** Includes a default and neon theme, inspired by Nike Run Club.
- **Progress Tracking:** Visualise fitness trends, weekly stats, and achievements with animated progress rings and graphs.
- **User Personalisation:** Customisable themes and settings, with options to manage health-related goals.

---

## Technology Stack
- **Swift and SwiftUI:** For seamless UI development and declarative design.
- **HealthKit API (Planned):** For tracking fitness metrics like steps and calories burned.
- **Screen Time API (Planned):** For app usage tracking and restriction.
- **GitLab:** Used for version control and collaborative development.

---

## Repository Structure
```
/
|-- product/           # Core project files for UnlockFit.
|-- documents/         # Reports, presentations, and related files.
|-- diary.md           # Project diary tracking progress and updates.
|-- README.md          # Overview of the project.
|-- .gitignore         # Excludes unnecessary files from version control.
```

---

## Current Progress
- **UI Development:** Core navigation and key views (Login, Profile, Fitness, Screen Time, Progress) have been implemented.
- **Dynamic Themes:** Users can switch between default and neon themes.
- **State Management:** Implemented `AppState` to handle navigation and theme updates.
- **Animations:** Added interactive progress rings, badges, and graph animations.
- **Version Control:** Repository is updated regularly with detailed commit messages.

---

## Upcoming Milestones
- **API Integration:** Connect HealthKit and Screen Time APIs for core functionality.
- **Custom Goal-Setting:** Allow users to create personalised fitness challenges.
- **Data Visualisation Enhancements:** Add detailed insights and trends based on user activity.
- **Community Features:** Explore options for shared challenges and leaderboards.

---

## How to Run
1. Clone this repository:
   ```bash
   git clone https://gitlab.com/[your-repo-url]
   ```
2. Open the project in Xcode.
3. Select your target device or simulator.
4. Build and run the project.

---

## Contributing
Contributions are welcome! If you'd like to contribute to UnlockFit, please fork the repository and create a pull request with your proposed changes.

---

## Contact
**Developer:** Nick Kohli  
**Supervisor:** Dr. Nguyen Khuong  
For any questions or feedback, please contact zlac300@live.rhul.ac.uk.
