import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding private var selectedImage: UIImage?

    init(selectedImage: Binding<UIImage?>) {
        _selectedImage = selectedImage
    }

    @Environment(\.presentationMode) private var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
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

    func updateUIViewController(
        _: UIImagePickerController,
        context _: UIViewControllerRepresentableContext<ImagePicker>
    ) {}
}
