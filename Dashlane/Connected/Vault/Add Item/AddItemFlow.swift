import CorePersonalData
import Foundation
import NotificationKit
import SwiftUI
import UIDelight

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
        AddItemView(
          items: items, title: title, didChooseItem: { viewModel.handleAddItemViewAction($0) })
      case .addPrefilledCredential:
        AddPrefilledCredentialView(model: viewModel.makeAddPrefilledCredentialViewModel())
          .detailContainerViewSpecificDismiss(.init { viewModel.completion(.dismiss) })
      case let .credentialDetail(config):
        CredentialDetailView(
          model: viewModel.makeCredentialDetailViewModel(
            credential: config.credential,
            prefilled: config.prefilled,
            generatedPassword: config.generatedPassword,
            actionPublisher: config.actionPublisher)
        )
        .detailContainerViewSpecificBackButton(.close)
        .detailContainerViewSpecificDismiss(.init { viewModel.completion(.dismiss) })
        .navigationBarHidden(true)
        .toasterOn()
      case .detail(let type):
        VaultDetailView(
          model: viewModel.makeDetailViewModel(), itemDetailViewType: type,
          dismiss: .init({ viewModel.completion(.dismiss) })
        )
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
