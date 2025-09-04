import SwiftUI
import UIKit
import VisionKit

public struct DocumentScannerView: UIViewControllerRepresentable {

  var completion: (Result<[UIImage], Error>) -> Void

  public init(completion: @escaping (Result<[UIImage], Error>) -> Void) {
    self.completion = completion
  }

  public func makeCoordinator() -> DocumentScanCoordinator {
    return DocumentScanCoordinator(parent: self)
  }

  public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
    let viewController = VNDocumentCameraViewController()
    viewController.delegate = context.coordinator
    return viewController
  }

  public func updateUIViewController(
    _ uiViewController: VNDocumentCameraViewController, context: Context
  ) {

  }

  public class DocumentScanCoordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    var parent: DocumentScannerView

    init(parent: DocumentScannerView) {
      self.parent = parent
    }

    public func documentCameraViewController(
      _ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan
    ) {
      controller.dismiss(animated: true) {
        DispatchQueue.global(qos: .userInitiated).async {
          var images = [UIImage]()
          for pageNumber in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            images.append(image)
          }
          self.parent.completion(.success(images))
        }
      }
    }

    public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController)
    {
      controller.dismiss(animated: true) {
        self.parent.completion(.success([]))
      }
    }

    public func documentCameraViewController(
      _ controller: VNDocumentCameraViewController, didFailWithError error: Error
    ) {
      controller.dismiss(animated: true) {
        self.parent.completion(.failure(error))
      }
    }
  }

}
