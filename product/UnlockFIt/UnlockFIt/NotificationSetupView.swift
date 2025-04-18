import SwiftUI

struct NotificationSetupView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("🔔 Notification Setup")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}

struct NotificationSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSetupView()
    }
}
