import SwiftUI

// PrivacyView displays the app’s privacy policy details in a scrollable view.
struct PrivacyView: View {
    // Environment objects providing global app state and theme configuration.
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager

    // The view body layers a black background and the privacy content.
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 0) {
                // Header title for the Privacy screen.
                Text("UnlockFit Privacy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 17)
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                // ScrollView containing all privacy policy sections.
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Section: explains how HealthKit data is used by the app.
                        Group {
                            Text("**Health Data Usage**")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("""
UnlockFit reads your **Steps**, **Active Energy (Calories)**, and **Flights Climbed** from HealthKit. We use this data solely to:
- Unlock screen-time sessions when you hit fitness milestones  
- Show you daily and weekly progress graphs  
- Sync your personal goals across your devices  
""")
                                .foregroundColor(.gray)
                        }
                        
                        // Section: details what profile and session data we collect and store.
                        Group {
                            Text("**Profile & Session Data**")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("""
UnlockFit stores your optional profile image, display name (nickname), and email address so you can personalise your experience. In addition, we track:
- **nickname**: your chosen display name  
- **profileImageURL**: link to your optional photo in Firebase Storage  
- **milestone data**: thresholds you set (e.g. step, calorie, flight milestones) and the last time they were updated (“milestoneLastUpdated”)  
- **screenTimeSessions**: a record of each session’s start time and duration  
- **screenTimeSeconds**: total seconds of screen time per day  
All of this data is attached to your unique user record so your settings and history persist across devices.
""")
                                .foregroundColor(.gray)
                        }
                        
                        // Section: describes Firebase Authentication and user identification.
                        Group {
                            Text("**Authentication & Identification**")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("""
We use **Firebase Authentication** to uniquely identify you and secure access to your data. Your email address is used as your login identifier, and Firebase issues a unique user ID (`uid`) that ties all your data together.
""")
                                .foregroundColor(.gray)
                        }
                        
                        // Section: describes what session records are saved for screen-time.
                        Group {
                            Text("**Session Data**")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("""
Each time you start and stop a session, we record:
- Start timestamp  
- Duration (hh:mm:ss)  
- Associated user UID  
We use this to display your total screen-time, percentage of average usage, and best-day summaries.
""")
                                .foregroundColor(.gray)
                        }
                        
                        // Section: outlines encryption and security measures for stored data.
                        Group {
                            Text("**Cloud Storage & Security**")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("""
All user data (profile info, goals, theme choice, session history) is stored under your unique Firebase Authentication UID in Firestore.  
- Data in transit is encrypted via HTTPS/TLS.  
- Firestore documents are protected by security rules so only you can read/write your own records.  
- No HealthKit data ever leaves your device except as the aggregated numbers written to your Firestore record — we never upload raw Health records.
""")
                                .foregroundColor(.gray)
                        }
                        
                        // Section: explains use of Firestore for real-time, document-based storage.
                        Group {
                            Text("**Firebase Firestore Storage**")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("""
We use **Firebase Firestore**, a cloud-hosted NoSQL database, to securely store and sync your data. Firestore features:
- **Document-based**: each user has a document under `users/{uid}` containing their profile and session data  
- **Encrypted in transit and at rest** by Google’s security infrastructure  
- **Fine-grained security rules** ensuring only you can read/write your own document  
- **Real-time synchronisation** so changes (e.g. new sessions, updated goals) propagate instantly across your devices  
""")
                                .foregroundColor(.gray)
                        }
                        
                        // Section: informs users of their control over permissions and data sharing.
                        Group {
                            Text("**Your Control & Consent**")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("""
- You choose when to grant HealthKit permissions; you can revoke them at any time in the Health app.  
- We never share your data with third parties for marketing or advertising.
""")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 17)
                    .padding(.bottom, 20)
                }
            }
        }
        
    }
}
