#if canImport(UIKit)

import UIKit
import SwiftUI
import UniformTypeIdentifiers

public extension View {

    func documentPicker(export fileURL: Binding<URL?>, completion: @escaping () -> Void) -> some View {
        background(
            DocumentPicker(.export(fileURL), completion: { _ in completion() })
        )
    }
    
    func documentPicker(open contentTypes: [UTType], isPresented: Binding<Bool>, completion: @escaping (Data?) -> Void) -> some View {
        background(
            DocumentPicker(.open(contentTypes, isPresented: isPresented), completion: completion)
        )
    }
}

private struct DocumentPicker: UIViewControllerRepresentable {

    enum Mode {
        case export(_ fileURL: Binding<URL?>)
        case open(_ contentTypes: [UTType], isPresented: Binding<Bool>)
    }

    private var mode: Mode
    private let completion: (Data?) -> Void

    init(_ mode: Mode, completion: @escaping (Data?) -> Void) {
        self.mode = mode
        self.completion = completion
    }

    func makeUIViewController(context: Context) -> DocumentPickerControllerWrapper {
        DocumentPickerControllerWrapper(mode: mode, completion: completion)
    }

    func updateUIViewController(_ controller: DocumentPickerControllerWrapper, context: Context) {
        controller.mode = mode
        controller.completion = completion
        controller.updateState()
    }
}

private final class DocumentPickerControllerWrapper: UIViewController, UIDocumentPickerDelegate, UIAdaptivePresentationControllerDelegate {

    var mode: DocumentPicker.Mode
    var completion: (Data?) -> Void

    init(mode: DocumentPicker.Mode, completion: @escaping (Data?) -> Void) {
        self.mode = mode
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateState()
    }

    fileprivate func updateState() {
        switch mode {
        case .export(let fileURL):
            guard fileURL.wrappedValue == nil else { break }
            if presentedViewController is UIDocumentPickerViewController {
                dismiss(animated: true)
            }
            return
        case .open(_, let isPresented):
            guard isPresented.wrappedValue == false else { break }
            if presentedViewController is UIDocumentPickerViewController {
                dismiss(animated: true)
            }
            return
        }
        guard presentedViewController == nil else { return }

        let controller: UIDocumentPickerViewController
        
        switch mode {
        case .export(let fileURL):
            controller = UIDocumentPickerViewController(forExporting: [fileURL.wrappedValue!])
        case .open(let contentTypes, _):
            controller = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
            controller.allowsMultipleSelection = false
        }

        controller.delegate = self
        controller.presentationController?.delegate = self
        present(controller, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard case .open = mode else {
            dismiss()
            return
        }
        guard let documentURL = urls.first, let data = try? Data(contentsOf: documentURL) else {
            dismiss()
            return
        }
        
        dismiss(data)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss()
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismiss()
    }

    private func dismiss(_ data: Data? = nil) {
        switch mode {
        case .export(let fileURL):
            fileURL.wrappedValue = nil
        case .open(_, let isPresented):
            isPresented.wrappedValue = false
        }
        completion(data)
    }
}

#endif
