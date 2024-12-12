import SwiftUI

extension View {
    func darkBackground() -> some View {
        self.background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
