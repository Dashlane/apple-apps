import SwiftUI
#if !os(macOS)

public extension View {
        func didAppear(_ perform: @escaping () -> Void) -> some View {
        self.background(DidAppearView(perform: perform))
    }
}

private struct DidAppearView: UIViewControllerRepresentable {
    let perform: () -> Void

    func makeUIViewController(context: Context) -> DidAppearViewController {
        DidAppearViewController(perform: perform)
    }

    func updateUIViewController(_ uiViewController: DidAppearViewController, context: Context) {

    }
}

private final class DidAppearViewController: UIViewController {
    let perform: () -> Void

    init(perform: @escaping () -> Void) {
        self.perform = perform
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        perform()
    }
}

#endif
