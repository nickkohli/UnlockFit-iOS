import SwiftUI

struct ThemesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select a Theme")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            // Toggles for themes
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: .constant(false)) {
                    Text("Default")
                        .foregroundColor(.white)
                }
                .toggleStyle(SwitchToggleStyle(tint: .purple))
                
                Toggle(isOn: .constant(false)) {
                    Text("Neon")
                        .foregroundColor(.white)
                }
                .toggleStyle(SwitchToggleStyle(tint: .purple))
            }

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView()
    }
}
