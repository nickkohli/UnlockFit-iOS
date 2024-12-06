//
//  ThemesView.swift
//  UnlockFIt
//
//  Created by woozy on 06/12/2024.
//


import SwiftUI

struct ThemesView: View {
    @State private var selectedTheme: String = "Default" // Default theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select a Theme")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            // Theme Options
            ForEach(["Default", "Neon"], id: \.self) { theme in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedTheme == theme },
                    set: { isOn in
                        if isOn { selectedTheme = theme }
                    }
                )) {
                    Text(theme)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .toggleStyle(SwitchToggleStyle(tint: .purple))
                .padding(.vertical, 5)
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
