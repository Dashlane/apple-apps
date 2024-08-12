import CoreCrypto
import CoreNetworking
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

@MainActor
public class ConfidentialSSOViewModel: ObservableObject, LoginKitServicesInjecting {

  @Published
  var loginService: ConfidentialSSOLoginHandler?
  let login: Login
  let nitroClient: NitroAPIClient
  let completion: Completion<SSOCompletion>

  public init(
    login: Login,
    nitroClient: NitroAPIClient,
    completion: @escaping Completion<SSOCompletion>
  ) {
    self.login = login
    self.nitroClient = nitroClient
    self.completion = completion
    Task {
      do {
        loginService = try await ConfidentialSSOLoginHandler(login: login, nitroClient: nitroClient)
      } catch {
        self.completion(.failure(error))
      }
    }
  }

  func didReceiveSAML(_ result: Result<String, Error>) {
    switch result {
    case let .success(saml):
      Task { @MainActor in
        await self.completeLogin(withSAML: saml)
      }
    case let .failure(error):
      self.completion(.failure(error))
    }
  }

  func completeLogin(withSAML saml: String) async {
    do {
      guard let loginService = loginService else {
        assertionFailure()
        return
      }
      let callbackInfos = try await loginService.callbackInfo(withSAML: saml)
      await MainActor.run {
        completion(.success(.completed(callbackInfos)))
      }
    } catch {
      await MainActor.run {
        completion(.failure(error))
      }
    }
  }

  func cancel() {
    self.completion(.success(.cancel))
  }
}
