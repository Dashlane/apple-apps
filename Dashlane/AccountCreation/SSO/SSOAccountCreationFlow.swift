import CoreLocalization
import CoreSession
import LoginKit
import SwiftUI
import UIDelight

@ViewInit
public struct SSOAccountCreationFlow: View {

  @StateObject
  var viewModel: SSOAccountCreationFlowViewModel

  public var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      ZStack {
        switch step {
        case .initial:
          EmptyView()
        case let .authenticate(serviceProviderUrl, isNitroProvider):
          SSOView(
            model: viewModel.makeSSOViewModel(
              serviceProviderUrl: serviceProviderUrl, isNitroProvider: isNitroProvider))
        case let .userConsent(ssoToken, serviceProviderKey):
          SSOUserConsentView(
            model: viewModel.makeUserConsentViewModel(
              ssoToken: ssoToken, serviceProviderKey: serviceProviderKey))
        }
      }.animation(.default, value: step)

    }.alert(using: $viewModel.errorItem) { item in
      switch item {
      case .validityError:
        Self.versionValidityAlert()
      case let .genericError(title):
        Alert(
          title: Text(title),
          dismissButton: .cancel(
            Text(CoreLocalization.L10n.Core.kwButtonOk),
            action: {
              Task {
                await viewModel.cancel()
              }
            }))
      }
    }
  }
}

extension View {
  fileprivate static func versionValidityAlert() -> Alert {
    return .init(
      title: Text(L10n.Localizable.validityStatusExpiredVersionNoUpdateTitle),
      message: Text(L10n.Localizable.validityStatusExpiredVersionNoUpdateDesc),
      dismissButton: .cancel(Text(L10n.Localizable.validityStatusExpiredVersionNoUpdateClose)))
  }
}
