import SwiftUI
import Foundation

struct ProfileView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState // Access AppState

    @State private var profileImage: UIImage? = UIImage(named: "placeholder") // Default image
    @State private var isImagePickerPresented = false // For photo picker

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Black background

                VStack(spacing: 0) { // Removed extra spacing
                    // Profile Section
                    HStack {
                        ZStack {
                            if let profileImage = profileImage {
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
                            Text("Nick Kohli")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("zlac300@live.rhul.ac.uk")
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
                            NavigationLink(destination: Text("Health Details")) {
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
                        appState.isLoggedIn = false // Log out and return to LoginView
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
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $profileImage)
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
        ProfileView()
            .environmentObject(ThemeManager()) // Provide a basic ThemeManager
            .environmentObject(GoalManager()) 
    }
}
