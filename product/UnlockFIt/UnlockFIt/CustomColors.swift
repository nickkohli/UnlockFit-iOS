import SwiftUI

extension Color {
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

struct CustomColors {
    // Fitness Rings - Primary (Ring end)
    static let ringRed = Color(hex: "#FF2891")
    static let ringGreen = Color(hex: "#D8FF00")
    static let ringBlue = Color(hex: "#00FFA9")

    // Fitness Rings - Secondary (Ring start)
    static let ringRed2 = Color(hex: "#F52615")
    static let ringGreen2 = Color(hex: "#90F600")
    static let ringBlue2 = Color(hex: "#00C8CF")

    // Nike Run Club Neon
    static let neonYellow = Color(hex: "#CFE640")
    static let neonYellow2 = Color(hex: "#66731A")
    
    // Ulku Theme - Hatsune Miku Blue
    static let ulkuBlue = Color(hex: "#39C5BB")
    static let ulkuBlue2 = Color(hex: "#006D7A")

    // Badges - Primary
    static let bronze = Color(hex: "#CC8040")
    static let silver = Color(hex: "#BFBFBF")
    static let gold = Color(hex: "#FFD700")
    static let platinum = Color(hex: "#E6E6ED")

    // Badges - Secondary (Much Darker)
    static let bronze2 = Color(hex: "#663300")
    static let silver2 = Color(hex: "#4D4D4D")
    static let gold2 = Color(hex: "#805900")
    static let platinum2 = Color(hex: "#808089")
    
    static let lightGray = Color(white: 0.6)
}
