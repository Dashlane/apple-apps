import CoreCrypto
import CoreNetworking
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import SwiftTreats

@MainActor
public class ConfidentialSSOViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting
{

  @Published
  var viewState: ViewState = .inProgress

  let login: Login
  let completion: Completion<SSOCompletion>
  @Published public var machine: ConfidentialSSOLoginStateMachine!
  @Published public var isPerformingEvent: Bool = false

  @MainActor
  lazy public var stateMachine: ConfidentialSSOLoginStateMachine = {
    machine
  }()

  enum ViewState: Equatable {
    case sso(
      _ authorisationURL: URL,
      _ injectionScript: String)
    case inProgress
  }

  public init(
    login: Login,
    nitroClient: NitroSSOAPIClient,
    logger: Logger,
    completion: @escaping Completion<SSOCompletion>
  ) {
    self.login = login
    self.completion = completion
    Task {
      do {
        machine = try await ConfidentialSSOLoginStateMachine(
          login: login,
          nitroClient: nitroClient,
          nitroSecureTunnelCreatorType: NitroSecureTunnelCreatorImpl.self,
          logger: logger)
        await perform(.fetchSSOInfo)
      } catch {
        self.completion(.failure(error))
      }
    }
  }

  public func update(
    for event: ConfidentialSSOLoginStateMachine.Event,
    from oldState: ConfidentialSSOLoginStateMachine.State,
    to newState: ConfidentialSSOLoginStateMachine.State
  ) async {
    switch (state, event) {
    case (.waitingForUserInput, _): break
    case (let .ssoInfoReceived(ssoInfo), _):
      self.viewState = .sso(ssoInfo.idpAuthorizeUrl, ssoInfo.injectionScript)
    case (let .receivedCallbackInfo(callbackInfos), _):
      self.completion(.success(.completed(callbackInfos)))
    case (.failed, _):
      self.completion(.failure(SSOAccountError.invalidServiceProviderKey))
    case (.cancelled, _):
      self.completion(.success(.cancel))
    }
  }

  func didReceiveSAML(_ result: Result<String, Error>) {
    Task {
      await self.perform(.didReceiveCallback(result))
    }
  }

  func cancel() async throws {
    await self.perform(.cancel)
  }
}
