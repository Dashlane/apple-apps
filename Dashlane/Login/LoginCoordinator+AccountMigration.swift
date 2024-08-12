import CoreSession
import CoreUserTracking
import DashlaneAPI
import Foundation

extension LoginCoordinator {
  func migrate(with migrationInfos: AccountMigrationInfos) {
    self.sessionServicesSubscription =
      SessionServicesContainer
      .buildSessionServices(
        from: migrationInfos.session,
        appServices: self.appServices,
        logger: sessionLogger,
        loadingContext: .remoteLogin()
      ) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(sessionServices):
          DispatchQueue.main.async {
            switch migrationInfos.type {
            case .ssoMemberToMpUser, .ssoMemberToAdmin:
              self.startAccountMigration(
                for: .remoteKeyToMasterPassword(migrationInfos.ssoAuthenticationInfo),
                sessionServices: sessionServices,
                authTicket: migrationInfos.authTicket?.value)
            case .mpUserToSSOMember:
              self.startAccountMigration(
                for: .masterPasswordToRemoteKey(migrationInfos.ssoAuthenticationInfo),
                sessionServices: sessionServices,
                authTicket: migrationInfos.authTicket?.value)
            case .undecodable:
              self.handle(error: UndecodableCaseError(SSOMigrationType.self))
            }
          }
        case let .failure(error):
          self.handle(error: error)
        }
      }

  }

  func startAccountMigration(
    for type: MigrationType,
    sessionServices: SessionServicesContainer,
    authTicket: String?
  ) {
    currentSubCoordinator = AccountMigrationCoordinator(
      type: type,
      navigator: navigator,
      sessionServices: sessionServices,
      authTicket: authTicket,
      logger: sessionLogger
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case .success(.cancel):
        self.completion(.logout)
      case .success(.finished(let session)):
        self.loadSessionServices(
          using: session,
          logInfo: .init(
            loginMode: .masterPassword, verificationMode: Definition.VerificationMode.none),
          isFirstLogin: true,
          isRecoveryLogin: false)
      case .failure(let error):
        self.handle(error: error)
      }
    }
    currentSubCoordinator?.start()
  }
}
