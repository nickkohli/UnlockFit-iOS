//
//  ViewModifiers.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//

import SwiftUI

extension View {
    func darkBackground() -> some View {
        self.background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
