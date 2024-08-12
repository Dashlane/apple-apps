import Combine
import CoreKeychain
import CorePersonalData
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UIKit

@MainActor
class LocalLoginMigrationCoordinator: Coordinator, SubcoordinatorOwner {
  enum Completion {
    case session(Session)
    case logout
  }

  let navigator: Navigator
  let appServices: AppServicesContainer
  let localLoginHandler: LocalLoginHandler
  let logger: Logger
  let completion: @MainActor (Result<Completion, Error>) -> Void
  let mode: LocalLoginFlowViewModel.Completion.MigrationMode
  var sessionServicesSubscription: AnyCancellable?
  internal var subcoordinator: Coordinator?
  let loginKitServices: LoginKitServicesContainer

  init(
    navigator: Navigator,
    appServices: AppServicesContainer,
    localLoginHandler: LocalLoginHandler,
    logger: Logger,
    mode: LocalLoginFlowViewModel.Completion.MigrationMode,
    completion: @escaping @MainActor (Result<Completion, Error>) -> Void
  ) {
    self.navigator = navigator
    self.appServices = appServices
    self.mode = mode
    self.localLoginHandler = localLoginHandler
    self.logger = logger
    self.completion = completion
    loginKitServices = appServices.makeLoginKitServicesContainer()
  }

  func start() {
    switch mode {
    case let .migrateAccount(migrationInfos):
      migrate(with: migrationInfos)
    case let .migrateAnalyticsId(session):
      migrateAnalyticsId(for: session)
    case let .migrateSsoKey(type, email):
      migrateSSOKeys(with: type, email: email)
    }
  }

  private func migrate(with migrationInfos: AccountMigrationInfos) {
    self.sessionServicesSubscription =
      SessionServicesContainer
      .buildSessionServices(
        from: migrationInfos.session,
        appServices: self.appServices,
        logger: self.logger,
        loadingContext: .remoteLogin()
      ) { [weak self] result in
        guard let self = self else { return }
        Task { @MainActor in
          switch result {
          case let .success(sessionServices):
            switch migrationInfos.type {
            case .ssoMemberToMpUser, .ssoMemberToAdmin:
              self.startAccountMigration(
                for: .remoteKeyToMasterPassword(migrationInfos.ssoAuthenticationInfo),
                sessionServices: sessionServices,
                authTicket: migrationInfos.authTicket)
            case .mpUserToSSOMember:
              self.startAccountMigration(
                for: .masterPasswordToRemoteKey(migrationInfos.ssoAuthenticationInfo),
                sessionServices: sessionServices,
                authTicket: migrationInfos.authTicket)
            case .undecodable:
              self.completion(.failure(UndecodableCaseError(SSOMigrationType.self)))
            }

            sessionServices.activityReporter.logSuccessfulLoginWithSso()
          case let .failure(error):
            self.completion(.failure(error))
          }
        }
      }
  }

  private func migrateSSOKeys(with type: SSOKeysMigrationType, email: String) {
    switch type {
    case let .localLogin(ssoKey, remoteKey):
      guard
        let oldSession = try? appServices.sessionContainer.loadSession(
          for: LoadSessionInformation(login: Login(email), masterKey: .ssoKey(remoteKey)))
      else {
        Task { @MainActor in
          self.completion(.failure(AccountError.unknown))
        }
        return
      }

      migrate(oldSession, ssoKey: ssoKey, remoteKey: remoteKey)

    case let .unlock(oldSession, ssoAuthenticationInfo):
      let model = SSOLocalLoginViewModel(
        deviceAccessKey: oldSession.configuration.keys.serverAuthentication.deviceId,
        ssoAuthenticationInfo: ssoAuthenticationInfo,
        ssoViewModelFactory: InjectedFactory(loginKitServices.makeSSOViewModel),
        ssoLocalStateMachineFactory: InjectedFactory(loginKitServices.makeSSOLocalStateMachine)
      ) { [weak self] result in
        self?.handleSSOResult(result, oldSession: oldSession)
      }
      let view = SSOLocalLoginView(model: model)
      navigator.present(UIHostingController(rootView: view), animated: true, completion: nil)
    }
  }

  private func handleSSOResult(
    _ result: Result<SSOLocalLoginViewModel.CompletionType, Error>, oldSession: Session
  ) {
    Task {
      do {
        let result = try result.get()
        switch result {
        case let .completed(ssoKeys):
          self.migrate(oldSession, ssoKey: ssoKeys.ssoKey, remoteKey: ssoKeys.remoteKey)
        case .cancel:
          self.completion(.success(.logout))
        }
      } catch {
        await MainActor.run {
          self.completion(.failure(error))
        }
      }
    }
  }

  private func migrate(_ session: Session, ssoKey: Data, remoteKey: Data) {
    do {
      let newSession = try appServices.sessionContainer.localMigration(
        of: session, ssoKey: ssoKey, remoteKey: remoteKey,
        config: appServices.sessionCryptoEngineProvider.defaultCryptoRawConfig(for: .ssoKey(ssoKey))
      )
      let masterKeyStatus = appServices.keychainService.masterKeyStatus(for: session.login)
      switch masterKeyStatus {
      case .available(let accessMode):
        try? appServices.keychainService.save(
          newSession.authenticationMethod.sessionKey.keyChainMasterKey,
          for: session.login,
          expiresAfter: AuthenticationKeychainService.defaultPasswordValidityPeriod,
          accessMode: accessMode)
      case .expired, .notAvailable:
        break
      }
      localLoginHandler.finish(with: newSession, isRecoveryLogin: false)
      Task { @MainActor in
        self.completion(.success(.session(session)))
      }
    } catch {
      Task { @MainActor in
        completion(.failure(error))
      }
    }
  }

  private func migrateAnalyticsId(for session: Session) {
    let userAPIClient = appServices.appAPIClient.makeUserClient(
      sessionConfiguration: session.configuration)
    Task {
      do {
        let result = try await userAPIClient.account.accountInfo()
        guard let user = result.userAnalyticsId, let device = result.deviceAnalyticsId else {
          throw AccountError.malformed
        }
        let ids = AnalyticsIdentifiers(device: device, user: user)
        let session = (try? self.appServices.sessionContainer.update(session, with: ids)) ?? session
        self.completion(.success(.session(session)))
      } catch {
        self.completion(.success(.session(session)))
      }
    }
  }
}

extension LocalLoginMigrationCoordinator {
  fileprivate func startAccountMigration(
    for type: MigrationType,
    sessionServices: SessionServicesContainer,
    authTicket: AuthTicket?
  ) {

    self.startSubcoordinator(
      AccountMigrationCoordinator(
        type: type,
        navigator: navigator,
        sessionServices: sessionServices,
        authTicket: authTicket?.value,
        logger: logger
      ) { [weak self] result in
        guard let self = self else {
          return
        }
        Task { @MainActor in
          switch result {
          case .success(.cancel):
            self.completion(.success(.logout))
          case .success(.finished(let session)):
            self.completion(.success(.session(session)))
          case .failure(let error):
            self.completion(.failure(error))
          }
        }
      })
  }
}
