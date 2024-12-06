//
//  CustomColors.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//


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
    // Fitness Rings - Primary
    static let ringRed = Color(hex: "#FF4355")
    static let ringGreen = Color(hex: "#66D966")
    static let ringBlue = Color(hex: "#4FA0FF")

    // Fitness Rings - Secondary (Much Darker)
    static let ringRed2 = Color(hex: "#660019")
    static let ringGreen2 = Color(hex: "#0D330D")
    static let ringBlue2 = Color(hex: "#002666")

    // Nike Run Club Neon
    static let neonYellow = Color(hex: "#E3FF38")
    static let neonYellow2 = Color(hex: "#66731A")

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
