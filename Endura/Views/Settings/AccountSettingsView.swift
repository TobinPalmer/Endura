//
// Created by Brandon Kirbyson on 7/31/23.
//

import Foundation
import SwiftUI
import UIKit
import FirebaseStorage
import FirebaseAuth

struct ImagePicker: UIViewControllerRepresentable {
    @Binding private var selectedImage: UIImage?

    init(selectedImage: Binding<UIImage?>) {
        self._selectedImage = selectedImage
    }

    @Environment(\.presentationMode) private var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage.crop(to: CGSize(width: 128, height: 128))
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}

fileprivate final class AccountSettingsViewModel: ObservableObject {
    func uploadProfileImage(imageData: Data) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        Storage.storage().reference().child("users/\(Auth.auth().currentUser!.uid)/profilePicture").putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading profile image: \(error)")
            }
        }
    }
}

struct AccountSettingsView: View {
    @ObservedObject private var viewModel = AccountSettingsViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?

    var body: some View {
        VStack {
            Text("Account")
            image?
                .resizable()
                .clipShape(Circle())
                .frame(width: 30, height: 30)
                .padding()
            image?
                .resizable()
                .clipShape(Circle())
                .frame(width: 200, height: 200)
                .padding()
            Button("Select Image") {
                self.showingImagePicker = true
            }
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(selectedImage: self.$inputImage)
                }
            Button("Save Changes") {
                if let imageData = inputImage?.pngData() {
                    viewModel.uploadProfileImage(imageData: imageData)
                }
            }
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else {
            return
        }
        image = Image(uiImage: inputImage)
    }
}

