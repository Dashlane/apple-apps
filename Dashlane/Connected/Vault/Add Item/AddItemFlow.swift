import CorePersonalData
import Foundation
import SwiftUI
import UIDelight
import NotificationKit

struct AddItemFlow: View {

    @StateObject
    var viewModel: AddItemFlowViewModel

    init(viewModel: @autoclosure @escaping () -> AddItemFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case let .addItem(items, title):
                AddItemView(items: items, title: title, didChooseItem: { viewModel.handleAddItemViewAction($0) })
            case .addPrefilledCredential(let model):
                AddPrefilledCredentialView(model: model)
                    .detailContainerViewSpecificDismiss(.init { viewModel.completion(.dismiss) })
            case .credentialDetail(let model):
                CredentialDetailView(model: model)
                    .detailContainerViewSpecificBackButton(.close)
                    .detailContainerViewSpecificDismiss(.init { viewModel.completion(.dismiss) })
                    .navigationBarHidden(true)
                    .toasterOn()
            case .detail(let type):
                viewModel.detailViewFactory.make(itemDetailViewType: type, dismiss: .init({ viewModel.completion(.dismiss) }))
                    .detailContainerViewSpecificBackButton(.close)
                    .navigationBarHidden(true)
                    .toasterOn()
            case .autofillDemoDummyFields(let credential):
                autofillDemoDummyFields(credential)
            }
        }
        .sheet(isPresented: $viewModel.showAutofillDemo) {
            AutofillOnboardingFlowView(model: viewModel.makeAutofillOnboardingFlowViewModel())
        }
        .sheet(item: $viewModel.autofillDemoDummyFieldsCredential) { credential in
            autofillDemoDummyFields(credential)
        }
    }

    @ViewBuilder
    private func autofillDemoDummyFields(_ credential: Credential) -> some View {
        viewModel.autofillDemoDummyFields(
            credential: credential,
            completion: { viewModel.handleAutofillDemoDummyFieldsAction($0) }
        )
    }
}
