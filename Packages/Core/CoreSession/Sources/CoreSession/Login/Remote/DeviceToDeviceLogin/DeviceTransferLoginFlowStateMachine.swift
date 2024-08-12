import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public struct DeviceTransferLoginFlowStateMachine: StateMachine {

  public enum State: Hashable {
    case awaitingTransferType(Login)

    case startSecurityChallengeFlow(SecurityChallengeFlowStateMachine.State, Login)

    case startQrCodeFlow(QRCodeFlowStateMachine.State)

    case pin(RegistrationData)

    case biometry(Biometry, RegistrationData)

    case readyToLoadAccount(RegistrationData)

    case startThirdPartyOTPFlow(
      ThirdPartyOTPLoginStateMachine.State, ThirdPartyOTPOption, AccountTransferInfo)

    case completed(RemoteLoginSession)

    case recovery(AccountRecoveryInfo, DeviceInfo)

    case cancel

    case error
  }

  public enum Event {
    case startSecurityChallengeFlow(Login)

    case startQRCodeFlow

    case dataReceived(AccountTransferInfo, TransferMethod)

    case accountRecoveryDidFinish(RegistrationData)

    case pinFinished(RegistrationData, Biometry?)

    case biometryFinished(RegistrationData)

    case loadAccount(RegistrationData)

    case otpDidFinish(RegistrationData)

    case startRecovery(Login)

    case errorOccurred

    case cancel
  }

  public var state: State

  let apiClient: AppAPIClient
  let login: Login?
  let deviceInfo: DeviceInfo
  let cryptoEngineProvider: CryptoEngineProvider
  let logger: Logger

  public init(
    login: Login?,
    deviceInfo: DeviceInfo,
    apiClient: AppAPIClient,
    sessionsContainer: SessionsContainerProtocol,
    logger: Logger,
    cryptoEngineProvider: CryptoEngineProvider
  ) {
    if let login {
      state = .awaitingTransferType(login)
    } else {
      state = .startQrCodeFlow(.startDeviceTransferQRCodeScan(.waitingForQRCodeScan))
    }
    self.login = login
    self.apiClient = apiClient
    self.deviceInfo = deviceInfo
    self.cryptoEngineProvider = cryptoEngineProvider
    self.logger = logger
  }

  mutating public func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch (state, event) {
    case (.awaitingTransferType, let .startSecurityChallengeFlow(login)):
      state = .startSecurityChallengeFlow(.startSecurityChallengeTransfer(.initializing), login)
    case (.awaitingTransferType, .startQRCodeFlow):
      state = .startQrCodeFlow(.startDeviceTransferQRCodeScan(.waitingForQRCodeScan))
    case (.startQrCodeFlow, .startQRCodeFlow):
      state = .startQrCodeFlow(.startDeviceTransferQRCodeScan(.waitingForQRCodeScan))
    case (.startQrCodeFlow, let .dataReceived(data, method)):
      await receivedDataFromSender(data, transferMethod: method)
    case (.startSecurityChallengeFlow, let .dataReceived(data, method)):
      await receivedDataFromSender(data, transferMethod: method)
    case (.recovery, let .dataReceived(data, method)):
      await receivedDataFromSender(data, transferMethod: method)
    case (.pin, let .pinFinished(data, biometry)):
      if let biometry {
        state = .biometry(biometry, data)
      } else {
        state = .readyToLoadAccount(data)
      }
    case (.biometry, let .biometryFinished(data)):
      state = .readyToLoadAccount(data)
    case (.startQrCodeFlow, .cancel) where login != nil:
      state = .awaitingTransferType(login!)
    case let (.startSecurityChallengeFlow(_, login), .cancel):
      state = .awaitingTransferType(login)
    case (_, .cancel):
      state = .cancel
    case (_, let .startRecovery(login)):
      do {
        let info = try await apiClient.accountRecoveryInfo(for: login)
        state = .recovery(info, deviceInfo)
      } catch {
        state = .error
      }
    case (_, let .loadAccount(data)):
      await loadAccount(with: data)
    case (.startThirdPartyOTPFlow, let .otpDidFinish(data)):
      await loadAccount(with: data)
    case (_, .errorOccurred):
      self.state = .error
    case (.recovery, let .accountRecoveryDidFinish(data)):
      if data.transferData.accountType == .invisibleMasterPassword {
        self.state = .pin(data)
      } else {
        self.state = .readyToLoadAccount(data)
      }
    default:
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
    logger.logInfo("Transition to state: \(state)")
  }
  mutating private func receivedDataFromSender(
    _ receivedData: AccountTransferInfo,
    transferMethod: TransferMethod
  ) async {

    do {
      guard let authTicket = receivedData.authTicket else {
        if receivedData.accountType == .masterPassword,
          let otpOption = try await apiClient.authentication.getAuthenticationMethodsForDevice(
            login: receivedData.login.email, methods: [.duoPush, .totp]
          ).verifications.loginMethod(for: receivedData.login)?.otpOption
        {
          self.state = .startThirdPartyOTPFlow(
            .initialize(otpOption.pushType), otpOption, receivedData)
          return
        }
        state = .error
        logger.error("No authTicket found, cannot continue")
        return
      }

      let data = RegistrationData(
        transferData: receivedData, authTicket: authTicket, transferMethod: transferMethod)

      switch receivedData.accountType {
      case .invisibleMasterPassword:
        self.state = .pin(data)
      default:
        self.state = .readyToLoadAccount(data)
      }
    } catch {
      logger.error("Transfer failed with error", error: error)
      state = .error
    }
  }

  mutating private func loadAccount(with loginData: RegistrationData) async {
    do {
      let type = try await registerDevice(with: loginData)
      self.state = .completed(type)
    } catch {
      logger.error("Device registration failed", error: error)
      state = .error
    }
  }

  private func authTicket(fromToken token: String, login: String) async throws -> AuthTicket {
    let result = try await apiClient.authentication.performExtraDeviceVerification(
      login: login, token: token)
    return AuthTicket(value: result.authTicket)
  }

  private func registerDevice(with loginData: RegistrationData) async throws -> RemoteLoginSession {
    let deviceRegistrationResponse = try await apiClient.authentication
      .completeDeviceRegistrationWithAuthTicket(
        device: deviceInfo, login: loginData.transferData.login.email,
        authTicket: loginData.authTicket.value)
    let registrationData = DeviceRegistrationData(
      initialSettings: deviceRegistrationResponse.settings.content,
      deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
      deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
      analyticsIds: AnalyticsIdentifiers(
        device: deviceRegistrationResponse.deviceAnalyticsId,
        user: deviceRegistrationResponse.userAnalyticsId),
      serverKey: deviceRegistrationResponse.serverKey,
      remoteKeys: deviceRegistrationResponse.remoteKeys,
      authTicket: loginData.authTicket.value)

    let remoteLoginSession: RemoteLoginSession
    switch loginData.transferData.accountType {
    case .masterPassword, .invisibleMasterPassword:

      remoteLoginSession = try await validateMasterKey(
        loginData.transferData.masterKey,
        login: loginData.transferData.login,
        authTicket: loginData.authTicket,
        remoteKey: nil,
        data: registrationData,
        isRecoveryLogin: loginData.isRecoveryLogin,
        newMasterPassword: loginData.newMasterPassword,
        pin: loginData.pin,
        shouldEnableBiometry: loginData.shouldEnableBiometry)
    case .sso:
      guard let ssoKey = loginData.transferData.ssoKey else {
        throw CryptoError.decryptionFailure
      }

      let ssoKeys = try cryptoEngineProvider.decipherRemoteKey(
        ssoKey: ssoKey, remoteKey: registrationData.remoteKeys?.ssoRemoteKey(),
        authTicket: loginData.authTicket)
      remoteLoginSession = try await validateMasterKey(
        loginData.transferData.masterKey,
        login: loginData.transferData.login,
        authTicket: loginData.authTicket,
        remoteKey: ssoKeys.remoteKey,
        data: registrationData,
        isRecoveryLogin: loginData.isRecoveryLogin,
        newMasterPassword: loginData.newMasterPassword,
        pin: loginData.pin,
        shouldEnableBiometry: loginData.shouldEnableBiometry)
    }
    return remoteLoginSession
  }

  private func validateMasterKey(
    _ masterKey: MasterKey,
    login: Login,
    authTicket: AuthTicket,
    remoteKey: Data? = nil,
    data: DeviceRegistrationData,
    isRecoveryLogin: Bool,
    newMasterPassword: String? = nil,
    pin: String?,
    shouldEnableBiometry: Bool
  ) async throws -> RemoteLoginSession {
    let masterKey = masterKey.masterKey(withServerKey: data.serverKey)

    let authentication = ServerAuthentication(
      deviceAccessKey: data.deviceAccessKey, deviceSecretKey: data.deviceSecretKey)

    let userDeviceAPIClient = apiClient.makeUserClient(
      login: login,
      signedAuthentication: authentication.signedAuthentication)

    let cryptoConfig = try await cryptoEngineProvider.retriveCryptoConfig(
      with: masterKey,
      remoteKey: remoteKey,
      encryptedSettings: data.initialSettings,
      userDeviceAPIClient: userDeviceAPIClient)

    return RemoteLoginSession(
      login: login,
      userData: data,
      cryptoConfig: cryptoConfig,
      masterKey: masterKey,
      authentication: authentication,
      remoteKey: remoteKey,
      isRecoveryLogin: isRecoveryLogin,
      newMasterPassword: newMasterPassword,
      authTicket: authTicket,
      pin: pin,
      shouldEnableBiometry: shouldEnableBiometry)

  }

}

public enum TransferMethod: String, Hashable {
  case accountRecoveryKey
  case qrCode
  case securityChallenge
}

extension AppAPIClient {
  func authTicket(fromToken token: String, login: String) async throws -> AuthTicket {
    let result = try await authentication.performExtraDeviceVerification(login: login, token: token)
    return AuthTicket(value: result.authTicket)
  }
}
