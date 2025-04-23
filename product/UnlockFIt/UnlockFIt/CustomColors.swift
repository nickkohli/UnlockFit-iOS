// CustomColors.swift contains color utilities and predefined palettes used throughout the app for consistent theming.
import SwiftUI

// Extension to allow initializing Color from a hex string (e.g., "#FF0000").
extension Color {
    // Initialize a SwiftUI Color by parsing a hex code (supports optional leading "#").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

// CustomColors holds static color definitions for rings, themes, and badges.
struct CustomColors {
    // Primary gradient end colors for fitness rings.
    // Fitness Rings - Primary (Ring end)
    static let ringRed = Color(hex: "#FF2891")
    static let ringGreen = Color(hex: "#D8FF00")
    static let ringBlue = Color(hex: "#00FFA9")

    // Secondary gradient start colors for fitness rings.
    // Fitness Rings - Secondary (Ring start)
    static let ringRed2 = Color(hex: "#F52615")
    static let ringGreen2 = Color(hex: "#90F600")
    static let ringBlue2 = Color(hex: "#00C8CF")

    // Neon theme colors (inspired by popular fitness apps).
    // Neon Theme - Nike Run Club Inspired
    static let neonYellow = Color(hex: "#CFE640")
    static let neonYellow2 = Color(hex: "#66731A")
    
    // Ulku theme colors (inspired by Hatsune Miku aesthetics).
    // Ulku Theme - Hatsune Miku Inspired
    static let ulkuBlue = Color(hex: "#39C5BB")
    static let ulkuBlue2 = Color(hex: "#006D7A")
    
    // Utility gray for disabled elements and dividers.
    static let lightGray = Color(white: 0.6)
}
