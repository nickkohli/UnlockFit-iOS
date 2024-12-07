//
//  AppState.swift
//  UnlockFIt
//
//  Created by woozy on 07/12/2024.
//


import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false // Tracks whether the user is logged in
}