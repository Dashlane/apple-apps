import CoreSession
import DashlaneAPI
import Foundation
import SwiftTreats

@MainActor
public class SSOViewModel: ObservableObject, LoginKitServicesInjecting {

  let ssoAuthenticationInfo: SSOAuthenticationInfo
  let confidentialSSOViewModelFactory: ConfidentialSSOViewModel.Factory
  let completion: Completion<SSOCompletion>

  var isNitroProvider: Bool {
    ssoAuthenticationInfo.isNitroProvider
  }

  public init(
    ssoAuthenticationInfo: SSOAuthenticationInfo,
    confidentialSSOViewModelFactory: ConfidentialSSOViewModel.Factory,
    completion: @escaping Completion<SSOCompletion>
  ) {
    self.ssoAuthenticationInfo = ssoAuthenticationInfo
    self.confidentialSSOViewModelFactory = confidentialSSOViewModelFactory
    self.completion = completion
  }

  func makeConfidentialSSOViewModel() -> ConfidentialSSOViewModel {
    return confidentialSSOViewModelFactory.make(
      login: ssoAuthenticationInfo.login, completion: completion)
  }

  func makeSelfHostedSSOLoginViewModel() -> SelfHostedSSOViewModel {
    return SelfHostedSSOViewModel(
      login: ssoAuthenticationInfo.login,
      authorisationURL: ssoAuthenticationInfo.serviceProviderUrl, completion: completion)
  }
}

extension SSOViewModel {
  static var mock: SSOViewModel {
    SSOViewModel(
      ssoAuthenticationInfo: .mock(),
      confidentialSSOViewModelFactory: .init({ login, completion in
        .init(login: login, nitroClient: .fake, completion: completion)
      }), completion: { _ in }
    )
  }
}
