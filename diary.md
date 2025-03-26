# UnlockFit - Project Diary

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
- `diary.md` for tracking weekly progress.
- A `product/` folder to store the core project files for the app.
- A `documents/` folder for reports and presentations.
- A `.gitignore` file to exclude unnecessary files such as simulator data.

An initial README.md file was created to summarise the project’s objectives and structure. I tested GitLab access by making initial test commits, confirming a smooth workflow.

---

This diary provides a detailed and chronological account of all significant milestones and progress made during the development of UnlockFit. It serves as a reflective tool to track achievements and areas of improvement throughout the project.
