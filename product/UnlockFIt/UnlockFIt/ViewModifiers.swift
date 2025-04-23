// ViewModifiers.swift: Defines reusable View extensions for consistent styling across the app.
import SwiftUI

// Extend all SwiftUI views with custom modifier methods.
extension View {
    // darkBackground applies a full-screen black background to any view.
    func darkBackground() -> some View {
        self.background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
