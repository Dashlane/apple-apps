import Foundation
import UIKit
import SwiftUI

struct ImageCaptureView: UIViewControllerRepresentable {

    enum CaptureError: Error {
        case badInput
        case cancel
    }

    var completion: (Result<UIImage, CaptureError>) -> Void

    init(completion: @escaping (Result<UIImage, CaptureError>) -> Void) {
        self.completion = completion
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImageCaptureView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImageCaptureView>) {

    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImageCaptureView

        init(parent: ImageCaptureView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            didSuccess(result: unwrapImage)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            didFail(reason: .cancel)
        }

        func didSuccess(result: UIImage) {
            parent.completion(.success(result))
        }

        func didFail(reason: CaptureError) {
            parent.completion(.failure(reason))
        }
    }
}
