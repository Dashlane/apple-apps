import AuthenticationServices
import CoreLocalization
import CorePersonalData
import CorePremium
import NotificationKit
import SwiftTreats
import SwiftUI
import TOTPGenerator
import UIComponents
import UserTrackingFoundation
import VaultKit

struct CredentialListView: View {
  @StateObject var model: CredentialListViewModel

  @Environment(\.report) private var report

  @Environment(\.dismissSearch)
  private var dismissSearch

  @Environment(\.openURL)
  private var openURL

  @CapabilityState(.autofillWithPhishingPrevention)
  var antiPhishingState

  let addCredentialPassword: () -> Void

  init(
    model: @escaping @autoclosure () -> CredentialListViewModel,
    addCredentialPassword: @escaping () -> Void
  ) {
    _model = .init(wrappedValue: model())
    self.addCredentialPassword = addCredentialPassword
  }

  @ViewBuilder
  var body: some View {
    ExtensionSearchView(model: model.makeExtensionSearchViewModel()) { item, origin in
      model.select(item, origin: origin)
    } placeholderAccessory: {
      placeholderAccessory
    } inactiveSearchView: {
      mainView
    }
    .animation(.easeInOut, value: model.isReady)
    .animation(.easeInOut, value: model.isSyncing)
    .navigationTitle(model.request.type.localizedTitle)
    .reportPageAppearance(.autofillExplorePasswords)
    .tint(.ds.text.brand.standard)
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
      toolbar
    }
  }

  @ToolbarContentBuilder
  var toolbar: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(CoreL10n.cancel) {
        model.cancel()
      }
    }
    ToolbarItem(placement: .navigationBarTrailing) {
      addButton
    }
  }

  @ViewBuilder
  private var addButton: some View {
    switch model.addState {
    case .available:
      AddCredentialButton {
        addCredential()
      }
    case .limitReached:
      AddCredentialButton {
        openPremiumPage()
      }
    case .unavailable:
      EmptyView()
    }
  }

  var placeholder: some View {
    ListPlaceholder(category: .credentials) {
      placeholderAccessory
    }
    .frame(maxWidth: .infinity)
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
  }

  @ViewBuilder
  var placeholderAccessory: some View {
    if model.addState == .available {
      Button(ItemCategory.credentials.placeholderCTATitle) {
        addCredential()
      }
      .buttonStyle(.designSystem(.titleOnly(.sizeToFit)))
    }
  }

  var mainView: some View {
    VStack(spacing: 0) {
      if !model.isReady {
        ProgressView()
          .progressViewStyle(.indeterminate)
          .frame(maxWidth: .infinity)
      } else if model.sections.isEmpty {
        placeholder
      } else {
        if model.isSyncing {
          ProgressView()
            .progressViewStyle(.indeterminate)
            .tint(.ds.text.brand.standard)
            .padding(.vertical, 10)
        }
        list
      }
    }
  }

  var list: some View {
    ItemsList(sections: model.sections) { row in
      HStack {
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

        if case CredentialsListRequest.RequestType.otps = model.request.type,
          case let .credential(credential) = row.vaultItem.enumerated,
          let otpURL = credential.otpURL
        {
          OTPTimeProgressAccessoryView(otpURL: otpURL)
            .padding(.trailing, 20)
        }
      }

    } header: {
      header
    }
    .indexed()
    .listStyle(.ds.plain)
  }

  @ViewBuilder
  private var header: some View {
    switch model.addState {
    case .available:
      Button {
        addCredential()
      } label: {
        AddCredentialListHeaderLabel()
      }
    case .limitReached:
      PasswordLimitReachedAnnouncementView {
        openPremiumPage()
      }
    case .unavailable:
      EmptyView()
    }
  }

  private func openPremiumPage() {
    guard
      let url = URL(
        string: "dashlane:///getpremium?paywall=\(CapabilityKey.passwordsLimit.rawValue)")
    else {
      return
    }

    let event = UserEvent.Click(button: .buyDashlane, clickOrigin: .bannerPasswordLimitReached)
    report?(event)

    openURL(url)
  }

  private func addCredential() {
    report?(UserEvent.AutofillClick(autofillButton: .createPasswordLabel))
    addCredentialPassword()
  }
}

private struct AddCredentialButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image.ds.action.add.outlined
    }
    .accessibilityLabel(L10n.Localizable.addNewPassword)
  }
}

private struct OTPTimeProgressAccessoryView: View {
  let otpURL: URL

  @State
  var configuration: OTPConfiguration?

  var body: some View {
    ZStack {
      switch configuration?.type {
      case let .totp(period: period):
        TimelineView(.animation) { _ in
          let progress = TOTPGenerator.progress(in: period)
          ProgressView(value: progress)
        }
        .progressViewStyle(.countdown)

      case .hotp, .none:
        EmptyView()
      }
    }
    .onChange(of: otpURL, initial: true) { _, otpURL in
      configuration = try? OTPConfiguration(otpURL: otpURL)
    }
    .accessibilityHidden(true)
  }
}

extension View {
  @ViewBuilder
  fileprivate func linkingViewContainer<V: View>(
    isPresented: Binding<Bool>, @ViewBuilder view: @escaping () -> V
  ) -> some View {
    if Device.is(.mac) {
      self.fullScreenCover(isPresented: isPresented) {
        view()
      }
    } else {
      self.sheet(isPresented: isPresented) {
        view()
          .presentationDetents([.large])
      }
    }
  }
}

extension CredentialsListRequest.RequestType {
  fileprivate var localizedTitle: String {
    switch self {
    case .passwords:
      L10n.Localizable.credentialProviderListTitlePasswords
    case .otps:
      L10n.Localizable.credentialProviderListTitleOtps
    case .passkeysAndPasswords:
      L10n.Localizable.credentialProviderListTitlePasskeys
    }
  }
}

extension Credential {
  var otpDigitCount: Int {
    if let otpURL = otpURL, let component = try? OTPConfiguration(otpURL: otpURL) {
      return component.digits
    } else {
      return 0
    }
  }
}

#Preview("Passwords") {
  CredentialListView(
    model: .mock(
      request: .init(
        servicesIdentifiers: [
          ASCredentialServiceIdentifier(identifier: "amazon.com", type: .domain)
        ], type: .passwords))
  ) {

  }
}

#Preview("OTPs") {
  CredentialListView(
    model: .mock(
      request: .init(
        servicesIdentifiers: [
          ASCredentialServiceIdentifier(identifier: "github.com", type: .domain)
        ], type: .otps))
  ) {

  }
}

#Preview("Passkeys") {
  CredentialListView(
    model: .mock(
      request: .init(
        servicesIdentifiers: [
          ASCredentialServiceIdentifier(identifier: "github.com", type: .domain)
        ], type: .passkeysAndPasswords(request: .mock)))
  ) {

  }
}
