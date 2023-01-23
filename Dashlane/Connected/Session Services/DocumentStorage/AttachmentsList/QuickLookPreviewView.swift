import QuickLook
import SwiftUI
import UIKit

struct QuickLookPreviewView: View {
    let dataSource: PreviewDataSource

    @Binding
    var showQuickLookPreview: Bool

    var body: some View {
        VStack(spacing: 0) {
            Button(L10n.Localizable.kwDoneButton) {
                showQuickLookPreview = false
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()

            PreviewController(dataSource: dataSource)
        }
    }
}

private struct PreviewController: UIViewControllerRepresentable {
    let dataSource: PreviewDataSource

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = dataSource
        return controller
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) { }

    class Coordinator: QLPreviewController { }
}
