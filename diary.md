# UnlockFit - Project Diary

---
This diary provides a detailed and chronological account of all significant milestones and progress made during the development of UnlockFit. It serves as a reflective tool to track achievements and areas of improvement throughout the project.
---

## **24th April 2025**
I completed the final polish and resolved the outstanding asset issues. The notification icon display was fixed by restoring the provisioning profile configuration and updating the CFBundleIcons entries. I verified that the icons rendered correctly on physical devices.

The app icon assets were refreshed to ensure consistency across all resolutions, and deprecated image sets were removed. I also conducted end-to-end smoke tests on both iPhone and iPad simulators to confirm there were no regressions in launch or notification behaviour.

---

## **23rd April 2025**
My focus was on code quality, internationalisation, and preparing for a feature walkthrough. I reviewed and refined all code comments, standardising terminology to British English and removing redundant annotations. Additionally, I temporarily disabled the release success overlay in ScreenTimeView to streamline the first public demonstration, while preserving the code for later reactivation.

I finalised the InstructionView content by adding detailed connectivity recommendations, minimum session duration guidance, and integrating illustrative screenshots. To help new users, I developed a step-by-step InstructionView walkthrough page complete with annotated visuals. Furthermore, I introduced four new themes — Performance, Slate, Aurora, and Cyberpunk — with defined accent colour pairings in ThemeManager and updated ThemesView accordingly.

---

## **22nd April 2025**
I enhanced the milestone tracking logic and improved user interface responsiveness. The milestone state loading and animation triggers were reordered to ensure that data is fetched prior to UI animation. FitnessView was updated to reflect real-time milestone progress at 25%, 50%, 75%, and 100%, with only a single unlock per data refresh.

The AppState milestone lock logic was refactored to animate overlay visibility when milestones are achieved or consumed. Informational overlays were added to explain milestone rules, unlimited session conditions, and the midnight reset behaviour. I also fixed the progress bar duplicate animation by introducing a first-appearance guard and smoothing transitions.

---

## **21st April 2025**
I completed the integration of the flights climbed metric and made several UI enhancements. The previous minute-based goal was replaced with flights climbed across all views, and I confirmed that HealthKit data retrieval and Firestore synchronisation were working correctly. A new 'Ulku' theme was added, featuring a turquoise-to-blue gradient, which was integrated into CustomColors and ThemeManager.

The double-bounce animation issue in FitnessView was resolved by delaying the ring animation trigger until HealthKit data stability was ensured. I implemented an animated greeting section in FitnessView with gradient nickname rendering and a fade-in effect. Additionally, the FitnessView refresh button was relocated and restyled, and debug messages were logged for background timer events.

---

## **20th April 2025**
I stabilised background refresh processes and improved chart interactions. Both automatic and manual refresh were enabled in FitnessView, with background timers that pause when the view is not visible. A refresh spinner and haptic feedback were implemented on the ProgressView reload action to enhance user experience.

Furthermore, I developed a weekly screen time bar chart featuring a sticky header and a scrollable layout. Smooth auto-scroll functionality was ensured on bar taps, making the interface more intuitive and responsive.

---

## **19th April 2025**
I addressed Firestore synchronisation and user session persistence. Screen time history was synced with Firestore, and the onboarding flow was adjusted to return to WelcomeView on logout. A goal save confirmation overlay was added, which includes confetti animation, haptic feedback, and button lockout until the save process completes.

To maintain consistency, default goal and theme values now persist after app relaunch by syncing AppState on MainTabView load. Profile image upload to Firebase Storage was integrated, and user nickname and email are loaded from Firestore to personalise the experience.

---

## **18th April 2025**
I established a robust authentication and registration flow by integrating the Firebase SDK via Swift Package Manager and configuring app-wide authentication setup. A RegisterView was added, which includes a nickname field, input validation, and navigation from LoginView. The Firebase registration logic was implemented to save default user data such as profile image URL, goals, and theme to Firestore.

I created NotificationSetupView and fixed environment object injection issues to enable a scrollable layout with a fixed header. The WelcomeView flow was refactored to reset the root view on login state change, and I validated the UIWindow override to ensure a secure reset process.

---

## **17th April 2025**
Finally finished the full Live Activity integration. Got the rotating ring in the Dynamic Island working and animating based on the timer progress — had some strange clipping issues at first but sorted it by adjusting padding and ring sizing. Also added a red flashing ring when the timer ends, which took a lot of trial and error to get the flashing to work properly with SwiftUI.

Set up time-sensitive notifications when a session ends to prompt the user to return to the app. I had to tweak the `UNNotificationContent` to make it bypass scheduled summary and appear instantly. I also tested this with a shorter 3 second timer to make testing easier.

Earlier today I managed to get the whole ScreenTimeLiveActivity component built and displaying on the Dynamic Island. At first, the visuals wouldn’t show unless the widget was added to the homescreen, but adding the `NSSupportsLiveActivities` key fixed that.

Session manager now has full start/pause/resume logic and the timer updates both locally and in the Live Activity. It was a big push today but everything’s feeling really smooth now.

---

## **26th March 2025**
Started wiring up HealthKit to weekly trend data for steps, calories, and minutes. Created a new `GoalManager` function to retrieve the past 7 days’ worth of data for each metric. Integrated that into the `ProgressView`, replacing the placeholder graph with a live, animated, multi-line graph.

Added new logic to display total weekly stats at the top of the screen in the "Weekly Overview" section. Used Swift’s number formatting to make large values easier to read (e.g. 12,450 steps instead of 12450).

Spent a lot of time debugging HealthKit issues — especially making sure the Info.plist was correctly configured and the data appeared when running on a real device. The app now requests permissions properly and displays live HealthKit data in both the fitness rings and the progress graph.

---

## **25th March 2025**
Kicked off the HealthKit API integration today. Created a dedicated `APIModule.swift` to manage API calls and set up the initial authorisation and step/calorie fetching functions. Got it running on my actual device to confirm that authorisation was working properly.

Also implemented a new `GoalManager` class that acts as the bridge between `APIModule` and the views. Hooked it up to `FitnessView` to update the ring animations with real data from HealthKit. Finally, I made sure the app requested HealthKit permissions and built cleanly with environment object injection working.

---

## **13th December 2024**
The `README.md` file was updated today, with all relevant information up to date.

---

## **12th December 2024**
Today, I focused on cleaning up unnecessary code comments across the project. This small yet significant task improved code readability and maintainability, making the codebase more professional and easier to navigate. Final visual updates were applied across all views, ensuring the app looked polished and presentable for the interim review.

---

## **7th December 2024**
Significant improvements were made to the `LoginView`. A gradient styling for the “Fit” text in the app logo was added, giving the branding a fresh and dynamic appearance. Layout and formatting issues in the login screen were resolved for a cleaner user experience. 

In the `ProfileView`, I introduced a logout button that allows users to navigate back to the login screen, improving functionality and user flow. To enhance navigation and manage theme-switching bugs, I implemented `AppState`, which streamlined the app’s state management. 

Additionally, I refined the visual formatting across `ProfileView`, `FitnessView`, and `ScreenTimeView`, making them more cohesive. Animations for progress graphs and badges were also completed, adding life to user interactions.

---

## **6th December 2024**
A major update was the introduction of a neon theme, inspired by Nike Run Club. This theme uses vibrant colours like neon yellow and purple, providing a motivational and energised feel to the app. To ensure colour consistency throughout the project, I updated `CustomColors` to use hex colour codes.

The `ProgressView` was enhanced with gradient badges and shadow effects, making it visually striking. I also created the `ThemesView`, where users can seamlessly switch between the default and neon themes. The profile page received significant updates, including options to manage health settings, move goals, and theme selection.

---

## **5th December 2024**
The foundation for the app’s navigation was laid today by implementing a dynamic tab bar. This feature allows users to easily navigate between Fitness, Screen Time, Progress, and Profile sections.

In `FitnessView`, I added interactive progress rings and goal tracking to make the fitness experience more engaging. The `ProgressView` was developed to display weekly stats, trend graphs, and achievements, helping users track their progress effectively.

---

## **4th December 2024**
The GitLab repository for UnlockFit was set up today to ensure proper version control and a structured development process. The repository includes:
 -  `diary.md` for tracking weekly progress.
 -  A `product/` folder to store the core project files for the app.
 -  A `documents/` folder for reports and presentations.
 -  A `.gitignore` file to exclude unnecessary files such as simulator data.

An initial README.md file was created to summarise the project’s objectives and structure. I tested GitLab access by making initial test commits, confirming a smooth workflow.

---
