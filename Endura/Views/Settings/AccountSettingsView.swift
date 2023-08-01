//
// Created by Brandon Kirbyson on 7/31/23.
//

import Foundation
import SwiftUI
import UIKit

extension UIImage {
    func crop(to targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / self.size.width
        let heightRatio = targetSize.height / self.size.height

        let scale = widthRatio > heightRatio ? widthRatio : heightRatio

        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgimage = newImage?.cgImage else {
            return nil
        }

        let contextImage: UIImage = UIImage(cgImage: cgimage)

        let posX = (newSize.width - targetSize.width) / 2
        let posY = (newSize.height - targetSize.height) / 2

        let rectToCrop: CGRect = CGRect(x: posX, y: posY, width: targetSize.width, height: targetSize.height)

        guard let imageRef: CGImage = contextImage.cgImage?.cropping(to: rectToCrop) else {
            return nil
        }

        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

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

struct AccountSettingsView: View {
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
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else {
            return
        }
        image = Image(uiImage: inputImage)
    }
}

