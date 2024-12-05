//
//  UnlockFItApp.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//

import SwiftUI
import UIKit

@main
struct UnlockFitApp: App {
    init() {
        UITabBar.appearance().barTintColor = UIColor.black // Background color for Tab Bar
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray // Unselected tabs
        UITabBar.appearance().tintColor = UIColor(.purple) // Selected tabs
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
