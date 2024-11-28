import AutofillKit
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreUserTracking
import DesignSystem
import NotificationKit
import PremiumKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct CredentialListView: View {
  @StateObject
  var model: CredentialListViewModel

  @Environment(\.dismissSearch)
  private var dismissSearch

  @Environment(\.openURL)
  private var openURL

  @CapabilityState(.autofillWithPhishingPrevention)
  var antiPhishingState

  init(model: @escaping @autoclosure () -> CredentialListViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    StepBasedNavigationView(steps: $model.steps) { step in
      switch step {
      case .list:
        list
      case .addCredential:
        AddCredentialView(model: model.makeAddCredentialViewModel())
      }
    }
  }

  @ViewBuilder
  var list: some View {
    ExtensionSearchView(
      model: model.makeExtensionSearchViewModel(),
      select: { model.select($0, origin: $1) }
    ) {
      VStack(spacing: 0) {
        if !model.isReady {
          ProgressViewBox()
            .frame(maxWidth: .infinity)
        } else if model.sections.isEmpty {
          ListPlaceholder(
            category: .credentials,
            accessory: addCredentialsPlaceholderButton.eraseToAnyView()
          )
          .frame(maxWidth: .infinity)
          .background(.ds.background.default)
        } else {
          if model.isSyncing {
            ProgressView()
              .tint(.ds.text.brand.standard)
              .padding(.vertical, 10)
          }
          listWithSuggestedItems
        }
      }
    }
    .animation(.easeInOut, value: model.isReady)
    .animation(.easeInOut, value: model.isSyncing)
    .navigationTitle(L10n.Localizable.tachyonCredentialsListTitle)
    .onAppear(perform: { model.onAppear() })
    .accentColor(.ds.text.brand.standard)
    .linkingViewContainer(
      isPresented: $model.displayLinkingView,
      view: {
        if antiPhishingState.isAvailable, let viewModel = model.makePhishingWarningViewModel() {
          PhishingWarningView(viewModel: viewModel)
        } else if let credentialLinkingViewModel = model.makeCredentialLinkingViewModel() {
          CredentialLinkingView(model: credentialLinkingViewModel)
        }
      }
    )
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        NavigationBarButton(
          action: { model.cancel() },
          title: CoreLocalization.L10n.Core.cancel)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        AddBarButton(
          style: .circle,
          action: {
            if model.canAddNewCredential() {
              addCredential()
            } else {
              openPremiumPage()
            }
          }
        )
        .foregroundColor(.ds.text.brand.standard)
        .accessibilityLabel(L10n.Localizable.addNewPassword)
      }
    }
  }

  var addCredentialsPlaceholderButton: some View {
    Button(ItemCategory.credentials.placeholderCtaTitle) {
      addCredential()
    }
    .buttonStyle(.designSystem(.titleOnly))
  }

  var listWithSuggestedItems: some View {
    ItemsList(sections: model.sections) { row in
      VaultItemRow(
        item: row.vaultItem,
        userSpace: nil,
        vaultIconViewModelFactory: model.vaultItemIconViewModelFactory
      )
      .onTapWithFeedback {
        model.select(
          row.vaultItem,
          origin: row.isSuggestedItem ? .suggestedItems : .regularList
        )
      }
    } header: {
      CredentialListViewHeader(mode: headerMode)
    }
    .indexed()
  }

}

extension CredentialListView {
  var headerMode: CredentialListViewHeader.Mode {
    if model.canAddNewCredential() {
      return .addCredential(action: { addCredential() })
    } else {
      return .cannotAddCredential(action: {
        let event = UserEvent.Click(button: .buyDashlane, clickOrigin: .bannerPasswordLimitReached)
        model.sessionActivityReporter.report(event)
        openPremiumPage()
      })
    }
  }

  private func openPremiumPage() {
    guard
      let url = URL(
        string: "dashlane:///getpremium?paywall=\(CapabilityKey.passwordsLimit.rawValue)")
    else {
      return
    }
    openURL(url)
  }

  private func addCredential() {
    model.sessionActivityReporter.report(
      UserEvent.AutofillClick(autofillButton: .createPasswordLabel))
    model.steps.append(.addCredential)
  }
}

extension View {

  @ViewBuilder
  fileprivate func linkingViewContainer<V: View>(
    isPresented: Binding<Bool>, @ViewBuilder view: @escaping () -> V
  ) -> some View {
    if Device.isMac {
      self.fullScreenCover(isPresented: isPresented, content: { view() })
    } else {
      self.bottomSheet(isPresented: isPresented, detents: [.large], content: { view() })
    }
  }
}
