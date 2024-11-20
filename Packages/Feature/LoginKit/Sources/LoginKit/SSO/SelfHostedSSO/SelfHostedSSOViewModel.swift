import AuthenticationServices
import CoreSession
import DashTypes
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public class SelfHostedSSOViewModel: NSObject, StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  let login: Login
  let authorisationURL: URL
  let completion: Completion<SSOCompletion>
  public var stateMachine: SelfHostedSSOLoginStateMachine

  public init(
    login: Login,
    authorisationURL: URL,
    logger: Logger,
    completion: @escaping Completion<SSOCompletion>
  ) {
    self.login = login
    self.authorisationURL = authorisationURL
    self.completion = completion
    stateMachine = SelfHostedSSOLoginStateMachine(login: login, logger: logger)
    super.init()
    startLogin()
  }

  public func update(
    for event: SelfHostedSSOLoginStateMachine.Event,
    from oldState: SelfHostedSSOLoginStateMachine.State,
    to newState: SelfHostedSSOLoginStateMachine.State
  ) async {
    switch (state, event) {
    case (.waitingForUserInput, _): break
    case (let .receivedcallbackInfo(callbackInfos), _):
      self.completion(.success(.completed(callbackInfos)))
    case (.failed, _):
      self.completion(.failure(SSOAccountError.invalidServiceProviderKey))
    case (.cancelled, _):
      self.completion(.success(.cancel))
    }
  }

  func cancel() {
    Task {
      await self.perform(.cancel)
    }
  }

  func startLogin() {
    let session = ASWebAuthenticationSession(url: authorisationURL, callbackURLScheme: "dashlane") {
      (callbackURL, error) in
      Task {
        await self.perform(.didReceiveCallback(callbackURL, error))
      }
    }
    session.presentationContextProvider = self
    session.prefersEphemeralWebBrowserSession = true
    session.start()
  }
}

extension SelfHostedSSOViewModel: ASWebAuthenticationPresentationContextProviding {
  public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    ASPresentationAnchor()
  }
}
