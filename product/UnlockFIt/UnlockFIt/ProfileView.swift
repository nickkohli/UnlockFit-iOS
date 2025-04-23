import SwiftUI
import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @State private var isImagePickerPresented = false
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) { // Removed extra spacing
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
                            isImagePickerPresented = true // Open image picker
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

                    // Settings Section
                    List {
                        Section(header: Text("Health Settings").foregroundColor(.gray)) {
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

                            NavigationLink(destination: Text("Units of Measure")) {
                                Label("Units of Measure", systemImage: "ruler.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))

                        Section(header: Text("App Settings").foregroundColor(.gray)) {
                            NavigationLink(destination: Text("Notifications Settings")) {
                                Label("Notifications", systemImage: "bell.fill")
                                    .foregroundColor(.yellow)
                            }

                            NavigationLink(destination: ThemesView()) {
                                Label("Themes", systemImage: "paintpalette.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))

                        Section(header: Text("Privacy").foregroundColor(.gray)) {
                            NavigationLink(destination: Text("Apple Fitness Privacy")) {
                                Label("Apple Fitness Privacy", systemImage: "lock.fill")
                                    .foregroundColor(.purple)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                    }
                    .scrollContentBackground(.hidden) // Hides the default list background

                    Spacer() // Push logout button to the bottom

                    // Logout Button
                    Button(action: {
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
                            .padding(.bottom, 10) // Add padding at the bottom
                    }
                }
                
                if showLogoutConfirmation {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    VStack(spacing: 20) {
                        Text("Are you sure you want to log out?")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 16) {
                            Button("Cancel") {
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel())
            .environmentObject(ThemeManager())
            .environmentObject(GoalManager())
    }
}
