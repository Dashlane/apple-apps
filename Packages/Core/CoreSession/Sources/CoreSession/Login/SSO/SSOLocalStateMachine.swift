import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public struct SSOLocalStateMachine: StateMachine {

  public enum State: Hashable {
    case waitingForUserInput
    case receivedSSOKeys(SSOKeys)
    case cancelled
    case failed
  }

  public enum Event {
    case receivedSSOCallback(Result<SSOCompletion, Error>)
    case cancel
  }

  public var state: State = .waitingForUserInput

  public let cryptoEngineProvider: CryptoEngineProvider
  public let apiClient: AppAPIClient
  private let ssoAuthenticationInfo: SSOAuthenticationInfo
  private let logger: Logger
  private let deviceAccessKey: String

  public init(
    ssoAuthenticationInfo: SSOAuthenticationInfo,
    deviceAccessKey: String,
    apiClient: AppAPIClient,
    cryptoEngineProvider: CryptoEngineProvider,
    logger: Logger
  ) {
    self.apiClient = apiClient
    self.cryptoEngineProvider = cryptoEngineProvider
    self.ssoAuthenticationInfo = ssoAuthenticationInfo
    self.deviceAccessKey = deviceAccessKey
    self.logger = logger
  }

  public mutating func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch (state, event) {
    case (.waitingForUserInput, let .receivedSSOCallback(result)):
      await handleSSOCallbackResult(result)
    case (_, .cancel):
      state = .cancelled
    default:
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
  }

  private mutating func handleSSOCallbackResult(_ result: Result<SSOCompletion, Error>) async {
    do {
      let result = try result.get()
      switch result {
      case let .completed(ssoCallbackInfos):
        await validateSSOTokenAndGetKeys(
          ssoCallbackInfos.ssoToken, serviceProviderKey: ssoCallbackInfos.serviceProviderKey)
      case .cancel:
        state = .cancelled
      }
    } catch {
      logger.error("SSO authentication failed", error: error)
      state = .failed
    }
  }

  private mutating func validateSSOTokenAndGetKeys(_ token: String, serviceProviderKey: String)
    async
  {
    do {
      let verificationResponse = try await apiClient.authentication.performSsoVerification(
        login: ssoAuthenticationInfo.login.email, ssoToken: token)
      let response = try await self.apiClient.authentication.completeLoginWithAuthTicket(
        login: self.ssoAuthenticationInfo.login.email,
        deviceAccessKey: deviceAccessKey,
        authTicket: verificationResponse.authTicket)
      let (encryptedRemoteKey, ssoKey) = try response.encryptedRemoteKeyAndSSOKey(
        usingKey: serviceProviderKey)
      let cryptoEngine = try cryptoEngineProvider.cryptoEngine(forKey: ssoKey)
      let decryptedRemoteKey = try cryptoEngine.decrypt(encryptedRemoteKey)
      let ssoKeys = SSOKeys(
        remoteKey: decryptedRemoteKey, ssoKey: ssoKey,
        authTicket: AuthTicket(value: verificationResponse.authTicket))
      state = .receivedSSOKeys(ssoKeys)
    } catch {
      logger.error("SSO validation failed", error: error)
      state = .failed
    }
  }
}

extension AppAPIClient.Authentication.CompleteLoginWithAuthTicket.Response {
  func encryptedRemoteKeyAndSSOKey(usingKey serviceProviderKey: String) throws -> (Data, Data) {
    guard let remoteKey = remoteKeys?.ssoRemoteKey(),
      let ssoServerKey = ssoServerKey
    else {
      throw SSOAccountError.userDataNotFetched
    }

    guard let serverKeyData = Data(base64Encoded: ssoServerKey),
      let serviceProviderKeyData = Data(base64Encoded: serviceProviderKey),
      let remoteKeyData = Data(base64Encoded: remoteKey.key)
    else {
      throw SSOAccountError.invalidServiceProviderKey
    }
    let ssoKey = serverKeyData ^ serviceProviderKeyData
    return (remoteKeyData, ssoKey)
  }
}
