import SwiftUI

// InstructionView provides a playful walkthrough of UnlockFit features and how to get the most out of the app.
struct InstructionView: View {
    // Environment objects providing app state and theming.
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 0) {
                // Header title
                Text("How UnlockFit Works")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Fitness section
                        Group {
                            Text("🏃🏽‍♂️ Fitness Section")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("UnlockFit uses HealthKit to track your **Steps**, **Active Energy (Calories)**, and **Flights Climbed**. Check the Daily Progress rings in the Fitness tab to see how close you are to your goals, and adjust your Move Goal slider to set new targets that update on your profile instantly.")
                                .foregroundColor(.gray)
                        }

                        // Unlock logic section
                        Group {
                            Text("🔓 Session Unlocking")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Your progress bar has 4 dots representing 25%, 50%, 75%, and 100% of each goal. When a milestone lights up white, you’ve earned part of a screen time session. Cash in any white dots to start a session - they’ll all reset together once you begin.")
                                .foregroundColor(.gray)
                        }

                        // ScreenTime section
                        Group {
                            Text("📱 Screen-Time Tab")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("In Screen Time, view today’s total usage, sessions completed, and compare your time saved against the average adult. The 7-day chart shows daily seconds or session counts. Tap a bar for details!")
                                .foregroundColor(.gray)
                        }

                        // Session behavior section
                        Group {
                            Text("⏲️ Sessions & Notifications")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("""
Sessions run in the background (Dynamic Island timer) and alert you when time’s up. The Dynamic Island ring flashes red when the session ends. You need to stop the session manually to log it, reinforcing your focus. The default recommended session is 10 minutes, but you can choose any duration from 1 minute to 1 hour. After your session ends, used dots turn black — you must earn new white dots for more sessions.
""")
                                .foregroundColor(.gray)
                        }

                        // Full-goal bonus section
                        Group {
                            Text("🏆 Full-Goal Bonus")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Hit all 3 goals in a day and enjoy unlimited sessions until midnight — even if all your milestone dots are black! At midnight, your health data (local), milestones, and screen time history reset for a fresh start.")
                                .foregroundColor(.gray)
                        }

                        // Progress tab section
                        Group {
                            Text("📊 Progress Tab")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("See your weekly fitness trends and discover your best day based on combined steps, calories, and flights. Use this insight to plan your next workout!")
                                .foregroundColor(.gray)
                        }

                        // Profile tab section
                        Group {
                            Text("👤 Profile Tab")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Customise your profile picture and nickname, review Health Access Details, change your move goal, manage notifications, pick themes, and read privacy info. Don’t forget you can log out here too!")
                                .foregroundColor(.gray)
                        }
                        
                        // Connectivity recommendation section
                        Group {
                            Text("🌐 Connectivity Recommended")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("""
For best results, use an internet connection (Wi‑Fi or cellular) so your goals, themes, and session history sync to the cloud. Working offline may risk losing logging data until you reconnect.
""")
                                .foregroundColor(.gray)
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView()
            .environmentObject(AppState())
            .environmentObject(ThemeManager())
    }
}
