//
//  FitnessView.swift
//  UnlockFit
//
//  Created by woozy on 05/12/2024.
//

import SwiftUI
import UIKit

struct ProfileView: View {
    @State private var profileImage: UIImage? = UIImage(named: "placeholder") // Default image
    @State private var isImagePickerPresented = false // For photo picker
    
    var body: some View {
            ZStack {
                // Black background
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                    // User Profile Picture and Info
                    Section {
                        HStack {
                            ZStack {
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(CustomColors.ringRed, lineWidth: 2))
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 70, height: 70)
                                        .overlay(Text("Add")
                                            .foregroundColor(.white))
                                }
                            }
                            
                            .onTapGesture {
                                isImagePickerPresented = true // Open image picker
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Nick Kohli")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("zlac300@live.rhul.ac.uk")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.all, 15.0)
                        .frame(width: 360.0)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .listRowBackground(Color.black) // Ensure row matches background
                    }
                
            }
            .navigationTitle("Profile")
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
