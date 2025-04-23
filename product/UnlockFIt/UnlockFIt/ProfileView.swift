// ProfileView.swift: UI for viewing and editing user profile, settings, and logout functionality.
import SwiftUI
import UIKit
import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

// ProfileView presents the user’s profile info, app settings links, and logout controls.
struct ProfileView: View {
    // ViewModel, environment objects, and state flags for image picker and logout confirmation.
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @State private var isImagePickerPresented = false
    @State private var showLogoutConfirmation = false

    // The view body builds the navigation, background, profile section, settings list, and logout overlay.
    var body: some View {
        // Wrap content in a navigation view for header and modal presentation.
        NavigationView {
            // ZStack layers a black background and the main VStack content, plus optional overlays.
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    // Screen title for profile settings.
                    Text("Profile Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 15)
                    
                    // Profile Section: shows profile image, nickname, and email with edit tap action.
                    // Profile Section
                    HStack {
                        ZStack {
                            if let profileImage = viewModel.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 80, height: 80)
                                    .overlay(Text("Add")
                                        .foregroundColor(.white))
                            }
                        }
                        .onTapGesture {
                            isImagePickerPresented = true
                        }

                        VStack(alignment: .leading) {
                            Text(viewModel.nickname)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(viewModel.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // Settings Section: navigation links for health details, goal changes, app settings, privacy & information.
                    // Settings Section
                    List {
                        // Section header for Health Settings settings.
                        Section(header: Text("Health Settings").foregroundColor(.gray) .frame(maxWidth: .infinity, alignment: .leading)) {
                            NavigationLink(destination: HealthPermissionView(isVisible: .constant(true), showDismiss: .constant(false))
                                .environmentObject(themeManager)
                                .environmentObject(appState)
                            ) {
                                Label("Health Details", systemImage: "heart.fill")
                                    .foregroundColor(.pink)
                            }

                            NavigationLink(destination: MoveGoalView()) {
                                Label("Change Move Goal", systemImage: "figure.walk")
                                    .foregroundColor(.green)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))

                        // Section header for App Settings settings.
                        Section(header: Text("App Settings").foregroundColor(.gray) .frame(maxWidth: .infinity, alignment: .leading)) {
                            Button(action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Label("Notifications", systemImage: "bell.fill")
                                    .foregroundColor(.yellow)
                            }

                            NavigationLink(destination: ThemesView()) {
                                Label("Themes", systemImage: "paintpalette.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))

                        // Section header for Privacy and Information
                        Section(header: Text("Information").foregroundColor(.gray) .frame(maxWidth: .infinity, alignment: .leading)) {
                            NavigationLink(destination: PrivacyView()
                                .environmentObject(appState)
                                .environmentObject(themeManager)
                            ) {
                                Label("UnlockFit Privacy", systemImage: "lock.fill")
                                    .foregroundColor(.purple)
                            }
                            NavigationLink(destination: InstructionView()
                                .environmentObject(appState)
                                .environmentObject(themeManager)
                            ) {
                                Label("How UnlockFit Works", systemImage: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                    }
                    .scrollContentBackground(.hidden)

                    Spacer()

                    // Logout Button: prompts confirmation before signing out.
                    // Logout Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .rigid)
                        generator.impactOccurred()
                        withAnimation {
                            showLogoutConfirmation = true
                        }
                    }) {
                        Text("Log Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(
                                gradient: Gradient(colors: [.red, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                }
                
                // Logout confirmation overlay with cancel and confirm actions.
                if showLogoutConfirmation {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    VStack(spacing: 20) {
                        // Confirmation prompt text.
                        Text("Are you sure you want to log out? ⚠️")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 16) {
                            Button("Cancel") {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation {
                                    showLogoutConfirmation = false
                                }
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [themeManager.accentColor, themeManager.accentColor2]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                withAnimation {
                                    showLogoutConfirmation = false
                                }
                                appState.isLoggedIn = false
                            }) {
                                Text("Log Out")
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.red, .pink]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .transition(.opacity)
                    .padding(30)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                }
            }
            .onAppear {
                print("\n")
                print("👤 ProfileView appeared")
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $viewModel.profileImage)
            }
        }
    }
}

// ImagePicker for selecting and uploading a new profile photo to Firebase Storage.
// Custom Image Picker
// UIKit wrapper to present the system image picker in SwiftUI.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    // Create and configure UIImagePickerController.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    // No-op update for the image picker controller.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // Create coordinator to handle picker delegate callbacks.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator implements UIImagePickerControllerDelegate to receive selected images.
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                parent.selectedImage = uiImage

                guard let imageData = uiImage.jpegData(compressionQuality: 0.7),
                      let uid = Auth.auth().currentUser?.uid else {
                    print("❌ Failed to get image data or user ID")
                    return
                }

                let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
                storageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("❌ Upload failed: \(error.localizedDescription)")
                        return
                    }

                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("❌ Failed to get download URL: \(error.localizedDescription)")
                            return
                        }

                        guard let downloadURL = url else { return }

                        Firestore.firestore().collection("users").document(uid).updateData([
                            "profileImageURL": downloadURL.absoluteString
                        ]) { err in
                            if let err = err {
                                print("❌ Firestore update error: \(err.localizedDescription)")
                            } else {
                                print("✅ Profile image URL updated successfully")
                            }
                        }
                    }
                }
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Preview provider for rendering ProfileView in Xcode canvas.
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel())
            .environmentObject(ThemeManager())
            .environmentObject(GoalManager())
    }
}
