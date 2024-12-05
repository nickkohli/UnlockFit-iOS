//
//  ProfileView.swift
//  UnlockFIt
//
//  Created by woozy on 05/12/2024.
//


import SwiftUI

struct ProfileView: View {
    @State private var profileImage: UIImage? = UIImage(named: "placeholder") // Default image
    @State private var isImagePickerPresented = false // For photo picker
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Picture and Info
                Section(header: Text("User Info")) {
                    HStack {
                        // Profile Picture
                        ZStack {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 80, height: 80)
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
                            Text("zlac300@live.rhul.ac.uk")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
                
                // App Settings
                Section(header: Text("Settings")) {
                    NavigationLink(destination: Text("Notifications Settings")) {
                        Label("Notifications", systemImage: "bell")
                    }
                    NavigationLink(destination: Text("Theme Preferences")) {
                        Label("Theme", systemImage: "paintpalette")
                    }
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy", systemImage: "lock.shield")
                    }
                }
                
                // Linked Apps
                Section(header: Text("Linked Apps")) {
                    NavigationLink(destination: Text("Apple Health")) {
                        Label("Apple Health", systemImage: "heart")
                    }
                    NavigationLink(destination: Text("Screen Time API")) {
                        Label("Screen Time", systemImage: "clock")
                    }
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $profileImage) // Custom Image Picker
            }
            .navigationTitle("Profile")
        }
    }
}

// Custom Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}