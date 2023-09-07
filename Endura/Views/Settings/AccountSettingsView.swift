import FirebaseAuth
import FirebaseStorage
import Foundation
import SwiftUI
import UIKit

private final class AccountSettingsViewModel: ObservableObject {
    @Published fileprivate var showingImagePicker = false
    @Published fileprivate var inputImage: UIImage?
    @Published fileprivate var image: Image?

    fileprivate func loadImage() {
        print("Loading image", inputImage.debugDescription)

        guard let inputImage else {
            return
        }

        print("Assining image")

        image = Image(uiImage: inputImage)
    }

    fileprivate func uploadProfileImage(imageData: Data) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        Storage.storage().reference().child("users/\(AuthUtils.getCurrentUID())/profilePicture").putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Error uploading profile image: \(error)")
            }
        }
    }
}

struct AccountSettingsView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @EnvironmentObject private var usersCache: UsersCacheModel

    @StateObject private var viewModel = AccountSettingsViewModel()

    var body: some View {
        VStack {
            Text("Account")

            ProfilePictureView(image: viewModel.image!)

//      if let image = viewModel.image {
//        ProfilePictureView(image: image)
//      } else {
//        if let profileImage = usersCache.getUserData(AuthUtils.getCurrentUID())?.profileImage {
//          ProfilePictureView(image: Image(uiImage: profileImage))
//        } else {
//          ProfilePictureView()
//        }
//      }

//      Button("Select Image") {
//        viewModel.showingImagePicker = true
//      }

            Button("Save Changes") {
                if let imageData = viewModel.inputImage?.pngData() {
                    viewModel.uploadProfileImage(imageData: imageData)
                }
            }
        }
        .onAppear {
            viewModel.loadImage()
        }
    }
}

private struct ProfilePictureView: View {
    @StateObject private var viewModel = AccountSettingsViewModel()

    private let imageDimensions = UIScreen.main.bounds.height / 5
    private let maxDimensions = 128.0

    private let image: Image
    @State private var hovering = false

    public init(image: Image = Image(systemName: "person.circle")) {
        self.image = image
    }

    public var body: some View {
        VStack {
            if hovering {
                ZStack {
                    image
                        .resizable()
                        .clipShape(Circle())
                        .frame(idealWidth: imageDimensions, maxWidth: maxDimensions, minHeight: imageDimensions, maxHeight: maxDimensions, alignment: .center)
                        .opacity(0.5)

                    Image(systemName: "camera")
                }
            } else {
                image
                    .resizable()
                    .clipShape(Circle())
//          .frame(idealWidth: imageDimensions, maxWidth: maxDimensions, minHeight: imageDimensions, maxHeight: maxDimensions, alignment: .center)
            }
        }
        .onTapGesture {
            print("Showing is true")
            viewModel.showingImagePicker = true
        }
        .onHover(perform: { hovering in
            if hovering {
                self.hovering = true
            } else {
                self.hovering = false
            }
        })
        .sheet(isPresented: $viewModel.showingImagePicker, onDismiss: viewModel.loadImage) {
            ImagePicker(selectedImage: $viewModel.inputImage)
        }
    }
}
