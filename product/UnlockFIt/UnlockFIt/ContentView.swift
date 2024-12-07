//
//  CustomColors.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LoginView() // Start with LoginView
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ThemeManager()) // Inject ThemeManager for preview
    }
}
