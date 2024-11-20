import CoreSession
import DashlaneAPI
import Foundation
import SwiftTreats

@MainActor
public class SSOViewModel: ObservableObject, LoginKitServicesInjecting {

  let ssoAuthenticationInfo: SSOAuthenticationInfo
  let selfHostedSSOViewModelFactory: SelfHostedSSOViewModel.Factory
  let confidentialSSOViewModelFactory: ConfidentialSSOViewModel.Factory
  let completion: Completion<SSOCompletion>

  var isNitroProvider: Bool {
    ssoAuthenticationInfo.isNitroProvider
  }

  public init(
    ssoAuthenticationInfo: SSOAuthenticationInfo,
    selfHostedSSOViewModelFactory: SelfHostedSSOViewModel.Factory,
    confidentialSSOViewModelFactory: ConfidentialSSOViewModel.Factory,
    completion: @escaping Completion<SSOCompletion>
  ) {
    self.ssoAuthenticationInfo = ssoAuthenticationInfo
    self.selfHostedSSOViewModelFactory = selfHostedSSOViewModelFactory
    self.confidentialSSOViewModelFactory = confidentialSSOViewModelFactory
    self.completion = completion
  }

  func makeConfidentialSSOViewModel() -> ConfidentialSSOViewModel {
    return confidentialSSOViewModelFactory.make(
      login: ssoAuthenticationInfo.login, completion: completion)
  }

  func makeSelfHostedSSOLoginViewModel() -> SelfHostedSSOViewModel {
    return selfHostedSSOViewModelFactory.make(
      login: ssoAuthenticationInfo.login,
      authorisationURL: ssoAuthenticationInfo.serviceProviderUrl, completion: completion)
  }
}

extension SSOViewModel {
  static var mock: SSOViewModel {
    SSOViewModel(
      ssoAuthenticationInfo: .mock(),
      selfHostedSSOViewModelFactory: .init({ login, authorisationURL, _ in
        SelfHostedSSOViewModel(
          login: login, authorisationURL: authorisationURL, logger: .mock, completion: { _ in })
      }),
      confidentialSSOViewModelFactory: .init({ login, completion in
        .init(login: login, nitroClient: .fake, logger: .mock, completion: completion)
      }), completion: { _ in }
    )
  }
}
