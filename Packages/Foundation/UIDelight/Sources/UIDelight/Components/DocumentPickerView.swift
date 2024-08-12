#if canImport(UIKit)
  import UIKit
  import Combine
  import SwiftUI
  import UniformTypeIdentifiers

  public struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding
    var fileUrl: URL?
    let supportedTypes: Set<String>

    public init(fileUrl: Binding<URL?>, supportedTypes: Set<String>) {
      self._fileUrl = fileUrl
      self.supportedTypes = supportedTypes
    }

    public func makeCoordinator() -> DocumentPickerCoordinator {
      return DocumentPickerCoordinator(fileUrl: $fileUrl, supportedTypes: supportedTypes)
    }

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
      let picker = UIDocumentPickerViewController(
        forOpeningContentTypes: [UTType.data], asCopy: true)
      picker.delegate = context.coordinator
      picker.allowsMultipleSelection = false
      return picker
    }

    public func updateUIViewController(
      _ uiViewController: UIDocumentPickerViewController, context: Context
    ) {

    }

    public class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
      @Binding
      var fileUrl: URL?
      let supportedTypes: Set<String>

      init(fileUrl: Binding<URL?>, supportedTypes: Set<String>) {
        self._fileUrl = fileUrl
        self.supportedTypes = supportedTypes
      }

      public func documentPicker(
        _ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]
      ) {
        guard controller.allowsMultipleSelection == false else {
          return
        }
        guard let url = urls.first else {
          return
        }
        var isDirectory: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        guard isDirectory.boolValue == false && fileExists else {
          return
        }
        guard supportedTypes.contains(url.pathExtension.lowercased()) else {
          return
        }
        self.fileUrl = url
      }
    }
  }
#endif
