import AuthenticatorKit
import Combine
import CoreFeature
import CorePersonalData
import DesignSystem
import NotificationKit
import SwiftTreats
import SwiftUI
import UIDelight
import VaultKit

struct VaultFlow: View {
  @ObservedObject
  var viewModel: VaultFlowViewModel

  init(viewModel: VaultFlowViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .home(let action):
        HomeView(
          model: viewModel.makeHomeViewModel(onboardingChecklistViewAction: action),
          activeFilter: $viewModel.activeFilter
        )
        .toolbar(.visible, for: .tabBar)
      case .vaultList(let category):
        VaultListView(model: viewModel.makeVaultListViewModel(category: category))
          .toolbar(.visible, for: .tabBar)

      case let .vaultDetail(item, type):
        detailView(for: item, viewType: type)
          .toolbar(.hidden, for: .tabBar)

      case .autofillDemoDummyFields(let credential):
        autofillDemoDummyFields(credential)
          .toolbar(.visible, for: .tabBar)
      }
    }
    .fullScreenCoverOrSheet(isPresented: $viewModel.showAddItemFlow) {
      NavigationView {
        AddItemFlow(viewModel: viewModel.makeAddItemFlowViewModel())
      }
    }
    .onReceive(viewModel.deeplinkPublisher) { deeplink in
      guard Device.isIpadOrMac, self.viewModel.canHandle(deepLink: deeplink) else { return }
      self.viewModel.handle(deeplink)
    }
    .sheet(isPresented: $viewModel.showAutofillFlow) {
      AutofillOnboardingFlowView(model: viewModel.makeAutofillOnboardingFlowViewModel())
    }
    .sheet(item: $viewModel.autofillDemoDummyFieldsCredential) { credential in
      autofillDemoDummyFields(credential)
    }
    .sheet(isPresented: $viewModel.showOnboardingChecklist) {
      OnboardingChecklistFlow(viewModel: viewModel.makeOnboardingChecklistFlowViewModel())
    }
  }

  @ViewBuilder
  private func autofillDemoDummyFields(_ credential: Credential) -> some View {
    viewModel.autofillDemoDummyFields(
      credential: credential,
      completion: { viewModel.handleAutofillDemoDummyFieldsAction($0) }
    )
  }

  @ViewBuilder
  private func detailView(for item: VaultItem, viewType: ItemDetailViewType) -> some View {
    VaultDetailView(model: viewModel.makeDetailViewModel(), itemDetailViewType: viewType)
      .navigationBarHidden(true)
  }
}

extension View {

  @ViewBuilder
  fileprivate func fullScreenCoverOrSheet<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    if Device.isIpadOrMac {
      sheet(isPresented: isPresented, content: content)
    } else {
      fullScreenCover(isPresented: isPresented, content: content)
    }
  }
}

extension VaultFlowViewModel.Mode {
  fileprivate var title: String {
    switch self {
    case .allItems:
      return L10n.Localizable.recentTitle
    case .category(let category):
      return category.title
    }
  }
}
