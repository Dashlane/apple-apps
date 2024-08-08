import AuthenticationServices
import Combine
import CorePersonalData
import CorePremium
import CoreSession
import CoreSync
import CoreUserTracking
import DashTypes
import Foundation
import LoginKit
import SwiftTreats

extension AccountMigrationCoordinator {
  func createMasterPasswordChangerService(
    withNewMasterPassword newMasterPassword: String,
    sessionServices: SessionServicesContainer,
    newVerification: Verification?,
    authTicket: CoreSync.AuthTicket?,
    type: AccountMigrationType
  ) async throws -> AccountCryptoChangerService {

    let masterPasswordBasedConfig = CryptoRawConfig.masterPasswordBasedDefault

    if type == .masterPasswordToMasterPassword {
      return try self.createMasterPasswordChangerService(
        withNewMasterPassword: newMasterPassword,
        sessionServices: sessionServices,
        newVerification: newVerification,
        authTicket: authTicket,
        type: type,
        cryptoConfig: masterPasswordBasedConfig)
    } else {
      let cryptoUserPayload = try? await fetchTeamSpaceCryptoConfigHeader()
      let config = CryptoRawConfig(
        fixedSalt: masterPasswordBasedConfig.fixedSalt,
        userMarker: masterPasswordBasedConfig.marker,
        teamSpaceMarker: cryptoUserPayload)
      return try self.createMasterPasswordChangerService(
        withNewMasterPassword: newMasterPassword,
        sessionServices: sessionServices,
        newVerification: newVerification,
        authTicket: authTicket,
        type: type,
        cryptoConfig: config)
    }
  }

  private func createMasterPasswordChangerService(
    withNewMasterPassword newMasterPassword: String,
    sessionServices: SessionServicesContainer,
    newVerification: Verification?,
    authTicket: CoreSync.AuthTicket?,
    type: AccountMigrationType,
    cryptoConfig: CryptoRawConfig
  ) throws -> AccountCryptoChangerService {

    let session = sessionServices.session
    let currentMasterKey = session.authenticationMethod.sessionKey

    let migratingSession = try sessionServices.appServices.sessionContainer.prepareMigration(
      of: session,
      to: .masterPassword(newMasterPassword, serverKey: currentMasterKey.serverKey), remoteKey: nil,
      cryptoConfig: cryptoConfig,
      accountMigrationType: type,
      loginOTPOption: type == .masterPasswordToMasterPassword
        ? session.configuration.info.loginOTPOption : nil)

    let postCryptoChangeHandler = PostMasterKeyChangerHandler(
      keychainService: sessionServices.appServices.keychainService,
      resetMasterPasswordService: sessionServices.resetMasterPasswordService,
      syncService: sessionServices.syncService)

    let reportedType: Definition.CryptoMigrationType =
      migratingSession.source.configuration.info.accountType == .sso
      ? .ssoToMasterPassword : .masterPasswordChange
    return try AccountCryptoChangerService(
      reportedType: reportedType,
      migratingSession: migratingSession,
      syncService: sessionServices.syncService,
      sessionCryptoUpdater: sessionServices.sessionCryptoUpdater,
      activityReporter: sessionServices.activityReporter,
      sessionsContainer: sessionServices.appServices.sessionContainer,
      databaseDriver: sessionServices.databaseDriver,
      postCryptoChangeHandler: postCryptoChangeHandler,
      apiClient: sessionServices.userDeviceAPIClient,
      authTicket: authTicket,
      logger: self.logger,
      cryptoSettings: cryptoConfig)

  }

  func createMasterPasswordChangerService(
    withServiceProviderKey serviceProviderKey: String,
    sessionServices: SessionServicesContainer,
    authTicket: String
  ) throws -> AccountCryptoChangerService {

    let ssoServerKey = Data.random(ofSize: 64)
    let remoteKey = Data.random(ofSize: 64)
    guard let serviceProviderKeyData = Data(base64Encoded: serviceProviderKey) else {
      throw AccountError.unknown
    }

    let ssoKey = ssoServerKey ^ serviceProviderKeyData

    let session = sessionServices.session
    let config = try sessionServices.appServices.sessionCryptoEngineProvider.defaultCryptoRawConfig(
      for: .ssoKey(ssoKey))
    let migratingSession = try sessionServices.appServices.sessionContainer.prepareMigration(
      of: session,
      to: .ssoKey(ssoKey),
      remoteKey: remoteKey,
      cryptoConfig: config,
      accountMigrationType: .masterPasswordToSSO,
      loginOTPOption: nil)
    let verification = Verification(
      type: .sso,
      ssoServerKey: ssoServerKey.base64EncodedString())

    let postCryptoChangeHandler = PostMasterKeyChangerHandler(
      keychainService: sessionServices.appServices.keychainService,
      resetMasterPasswordService: sessionServices.resetMasterPasswordService,
      syncService: sessionServices.syncService)

    return try AccountCryptoChangerService(
      reportedType: .masterPasswordToSso,
      migratingSession: migratingSession,
      syncService: sessionServices.syncService,
      sessionCryptoUpdater: sessionServices.sessionCryptoUpdater,
      activityReporter: sessionServices.activityReporter,
      sessionsContainer: sessionServices.appServices.sessionContainer,
      databaseDriver: sessionServices.databaseDriver,
      postCryptoChangeHandler: postCryptoChangeHandler,
      apiClient: sessionServices.userDeviceAPIClient,
      authTicket: AuthTicket(token: authTicket, verification: verification),
      logger: logger,
      cryptoSettings: migratingSession.target.cryptoConfig)
  }

  func fetchTeamSpaceCryptoConfigHeader() async throws -> CryptoEngineConfigHeader? {
    let status = try await sessionServices.userDeviceAPIClient.premium.getPremiumStatus()
    guard status.b2bStatus?.statusCode == .inTeam else {
      return nil
    }

    return status.b2bStatus?.currentTeam?.teamInfo.cryptoForcedPayload
  }

  func showSSOLogin(with validator: SSOAuthenticationInfo) {
    authenticate(with: validator) { result in
      switch result {
      case let .success((authTicket, serviceProviderKey)):
        DispatchQueue.main.async {
          self.startChangeMasterKey(
            withAuthTicket: authTicket, serviceProviderKey: serviceProviderKey)
        }
      case let .failure(error):
        self.completion(.failure(error))
      }
    }
  }

  func authenticate(
    with ssoAuthenticationInfo: SSOAuthenticationInfo,
    completion: @escaping CompletionBlock<(String, String), Swift.Error>
  ) {
    let model = SSOViewModel(
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      confidentialSSOViewModelFactory: InjectedFactory(
        loginKitServices.makeConfidentialSSOViewModel)
    ) { result in

      Task { @MainActor in
        do {
          let result = try result.get()
          switch result {
          case let .completed(callbackInfos):
            if let authTicket = self.authTicket {
              completion(.success((authTicket, callbackInfos.serviceProviderKey)))
            } else {
              let keys = try await self.validateSSOToken(with: callbackInfos)
              completion(.success(keys))
            }
          case .cancel:
            self.completion(.success(.cancel))
          }
        } catch {
          self.navigator.pop()
          completion(.failure(error))
        }
      }
    }
    navigator.push(SSOView(model: model))
  }

  private func validateSSOToken(with callbackInfos: SSOCallbackInfos) async throws -> (
    String, String
  ) {
    let verificationResponse = try await sessionServices.appServices.appAPIClient.authentication
      .performSsoVerification(
        login: sessionServices.session.login.email, ssoToken: callbackInfos.ssoToken)
    return (verificationResponse.authTicket, callbackInfos.serviceProviderKey)
  }
}
