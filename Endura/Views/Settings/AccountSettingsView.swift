import AlertKit
import FirebaseAuth
import FirebaseStorage
import Foundation
import SwiftUI
import UIKit

private final class AccountSettingsViewModel: ObservableObject {
    @Published fileprivate var uploadedImage: Image?
    @Published fileprivate var inputImage: UIImage?

    fileprivate final func loadImage() {
        guard let inputImage = inputImage else {
            return
        }

        uploadedImage = Image(uiImage: inputImage)

        guard let imageData = inputImage.pngData() else {
            AlertKitAPI.present(
                title: "Profile Image Upload Failed",
                icon: .error,
                style: .iOS17AppleMusic,
                haptic: .error
            )

            return
        }

        AlertKitAPI.present(
            title: "Profile Image Uploaded",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )

        uploadProfileImage(imageData)
    }

    private func uploadProfileImage(_ imageData: Data) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        Storage.storage().reference().child("users/\(AuthUtils.getCurrentUID())/profilePicture")
            .putData(imageData, metadata: metadata) { _, error in
                if let error = error {
                    Global.log.error("Error uploading profile image: \(error)")
                }
            }
    }
}

struct AccountSettingsView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @EnvironmentObject private var usersCache: UsersCacheModel
    @State private var showingImagePicker = false

    @StateObject private var viewModel = AccountSettingsViewModel()

    public var body: some View {
        VStack {
            if let image = viewModel.inputImage ?? usersCache.getUserData(AuthUtils.getCurrentUID())?.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 128, height: 128)
                    .onTapGesture(perform: {
                        showingImagePicker = true
                    })
                    .sheet(isPresented: $showingImagePicker, onDismiss: viewModel.loadImage) {
                        ImagePicker(selectedImage: $viewModel.inputImage)
                    }
            }

            Text("Account")
        }
    }
}
