import SwiftUI

struct HealthPermissionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("Health Access Needed")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("UnlockFit needs access to your step count, calories burned, and flights climbed to track your progress and unlock your goals.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open Settings")
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    isVisible = false
                }) {
                    Text("Dismiss")
                        .foregroundColor(.gray)
                        .underline()
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
}

struct HealthPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        HealthPermissionView(isVisible: .constant(true))
    }
}
