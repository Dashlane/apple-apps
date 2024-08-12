#if canImport(UIKit)
  import SwiftUI
  import UIKit
  import Combine
  import UniformTypeIdentifiers

  public struct ImagePicker: UIViewControllerRepresentable {
    public typealias ImageData = (image: Data, fileUrl: URL?)

    @Binding
    var imageData: ImageData?

    let sourceType: UIImagePickerController.SourceType

    public init(imageData: Binding<ImageData?>, sourceType: UIImagePickerController.SourceType) {
      self._imageData = imageData
      self.sourceType = sourceType
    }

    public func makeCoordinator() -> ImagePickerCoordinator {
      return ImagePickerCoordinator(imageData: $imageData)
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
      let picker = UIImagePickerController()
      picker.delegate = context.coordinator
      picker.sourceType = sourceType
      return picker
    }

    public func updateUIViewController(
      _ uiViewController: UIImagePickerController, context: Context
    ) {

    }

    public class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate,
      UINavigationControllerDelegate
    {
      @Binding
      var imageData: ImageData?

      init(imageData: Binding<ImageData?>) {
        self._imageData = imageData
      }

      public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
      }

      public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
      ) {

        picker.dismiss(animated: true) {
          switch picker.sourceType {
          case .camera:
            guard let image = info[.originalImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 1.0)
            else {
              return
            }
            self.imageData = (image: imageData, fileUrl: nil)
          default:
            var url: URL?
            if let imageUrl = info[.imageURL] as? URL {
              url = imageUrl
            } else if let mediaUrl = info[.mediaURL] as? URL {
              url = mediaUrl
            }

            guard let image = info[.originalImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 1.0)
            else {
              return
            }
            self.imageData = (image: imageData, fileUrl: url)
          }
        }
      }
    }
  }
#endif
