import SwiftUI

struct HealthPermissionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isVisible: Bool
    @Binding var showDismiss: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let _ = print("👀 showDismiss is now: \(showDismiss)")
        ZStack(alignment: .top) {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) {
                Text("Health Access Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("UnlockFit needs access to your step count, calories burned, and flights climbed to track your progress and unlock your goals.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                // ── Health Details Explanation ──
                VStack(alignment: .leading, spacing: 12) {
                    Text("How UnlockFit Uses Health Data:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("""
                    • Tracks your steps, active calories, and flights climbed  
                    • Unlocks screen‑time sessions at fitness milestones  
                    • Syncs your progress across devices securely  
                    """)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Placeholder image for recommended settings
                    VStack {
                        Image("health_perms")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .border(Color.gray.opacity(0.3))
                        
                        Text("Recommended: Allow “Steps,” “Active Energy,” and “Flights Climbed”")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)

                Button(action: {
                    if let url = URL(string: "x-apple-health://") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open Health Settings")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor2]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if showDismiss {
                    Button(action: {
                        isVisible = false
                    }) {
                        Text("Dismiss")
                            .foregroundColor(.gray)
                            .underline()
                    }
                    .padding(.top, 10)
                }
            }
            .padding()
            .padding(.top, 5)
        }
    }
}

struct HealthPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        HealthPermissionView(isVisible: .constant(true), showDismiss: .constant(true))
            .environmentObject(ThemeManager())
    }
}
