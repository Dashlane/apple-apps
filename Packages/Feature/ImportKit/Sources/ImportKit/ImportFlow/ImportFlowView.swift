import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct ImportFlowView<Model: ImportFlowViewModel>: View {

        @ObservedObject
    var viewModel: Model

    var completion: ((ImportDismissAction) -> Void)?

    public init(viewModel: Model, completion: ((ImportDismissAction) -> Void)? = nil) {
        self.viewModel = viewModel
        self.completion = completion
    }

    public var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .intro(let model):
                ImportInformationView(model: model, action: viewModel.handleIntroAction)
            case .instructions(let model):
                ImportInformationView(model: model, action: viewModel.handleInstructionsAction)
            case .extension(let model):
                ImportInformationView(model: model, action: viewModel.handleExtensionAction)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(L10n.Core.kwButtonClose) {
                    completion?(.dismiss)
                }
                .hidden(!viewModel.shouldDisplayRootBackButton)
            }
        }
        .sheet(isPresented: $viewModel.showPasswordView) {
            DashImportPasswordView(model: viewModel.makeImportPasswordViewModel(), action: viewModel.handlePasswordAction)
        }
        .onReceive(viewModel.dismissPublisher) {
            self.completion?($0)
        }
    }
}
