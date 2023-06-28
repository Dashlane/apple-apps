import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight
import UniformTypeIdentifiers

public struct ImportFlowView<Model: ImportFlowViewModel>: View {

        @ObservedObject
    var viewModel: Model

    var completion: ((ImportDismissAction) -> Void)?

    @State private var isDropping = false

    public init(viewModel: Model, completion: ((ImportDismissAction) -> Void)? = nil) {
        self.viewModel = viewModel
        self.completion = completion
    }

    public var body: some View {
        let dropper = Dropper(active: $isDropping, fileData: $viewModel.fileData)
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .intro(let model):
                ImportInformationView(model: model,
                                      action: viewModel.handleIntroAction,
                                      isLoading: $viewModel.isLoading)
            case .instructions(let model):
                ImportInformationView(model: model,
                                      action: viewModel.handleInstructionsAction,
                                      isLoading: $viewModel.isLoading)
            case .extension(let model):
                ImportInformationView(model: model,
                                      action: viewModel.handleExtensionAction,
                                      isLoading: $viewModel.isLoading)
            case .list(let model):
                if let model = model as? Model.AnyImportViewModel {
                    ImportListView(model: model, action: viewModel.handleListAction)
                } else {
                    fatalError("\(model) was created with a different kind of ImportViewModel, or does not conform to ObservableObject")
                }
            case .error(let model):
                ImportErrorView(model: model, action: viewModel.handleErrorAction)
            }
        }
        .navigationBarStyle(.transparent(tintColor: .ds.text.brand.standard, titleColor: nil))
        .sheet(isPresented: $viewModel.showPasswordView) {
            DashImportPasswordView(model: viewModel.makeImportPasswordViewModel(), action: viewModel.handlePasswordAction)
        }
        .onReceive(viewModel.dismissPublisher) {
            self.completion?($0)
        }
        .onCSVFileDrop(isDroppingFileEnabled: viewModel.isDroppingFileEnabled,
                       dropper: dropper)
    }
}

private extension View {
    @ViewBuilder
    func onCSVFileDrop(isDroppingFileEnabled: Bool, dropper: Dropper) -> some View {
        if isDroppingFileEnabled {
            self
                .onDrop(of: [.commaSeparatedText], delegate: dropper)
                .overlay {
                    if dropper.active {
                        DropFileOverlay()
                            .edgesIgnoringSafeArea(.all)
                            .onDrop(of: [.commaSeparatedText], delegate: dropper)
                    }
                }
        } else {
            self
        }
    }
}

private struct Dropper: DropDelegate {
    @Binding var active: Bool
    @Binding var fileData: Data?

    func performDrop(info: DropInfo) -> Bool {
        active = false
        guard let item = info.itemProviders(for: [.commaSeparatedText]).first else { return false }
        item.loadItem(forTypeIdentifier: UTType.commaSeparatedText.identifier, options: nil) { (urlData, _) in
            DispatchQueue.main.async {
                if let url = urlData as? URL {
                    fileData = try? Data(contentsOf: url)
                }
            }
        }
        return true
    }

    func dropEntered(info: DropInfo) {
        self.active = true
    }

    func dropExited(info: DropInfo) {
        self.active = false
    }
}
