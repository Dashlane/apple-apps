import AuthenticationServices
import CoreSession
import DashTypes
import Foundation
import SwiftTreats

@MainActor
public class SelfHostedSSOViewModel: NSObject, ObservableObject {

  let login: Login
  let authorisationURL: URL
  let completion: Completion<SSOCompletion>

  public init(
    login: Login,
    authorisationURL: URL,
    completion: @escaping Completion<SSOCompletion>
  ) {
    self.login = login
    self.authorisationURL = authorisationURL
    self.completion = completion
    super.init()
    startLogin()
  }

  func didReceiveCallback(_ result: (URL?, Error?)) {
    guard let callbackURL = result.0 else {
      self.cancel()
      return
    }

    guard let callbackInfos = SSOCallbackInfos(url: callbackURL) else {
      self.completion(.failure(AccountError.unknown))
      return
    }
    self.completion(.success(.completed(callbackInfos)))

  }

  func cancel() {
    self.completion(.success(.cancel))
  }

  func startLogin() {
    let session = ASWebAuthenticationSession(url: authorisationURL, callbackURLScheme: "dashlane") {
      (callbackURL, error) in
      self.didReceiveCallback((callbackURL, error))
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
