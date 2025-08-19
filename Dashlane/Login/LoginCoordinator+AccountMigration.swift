import CoreSession
import DashlaneAPI
import Foundation
import LoginKit
import UserTrackingFoundation

extension LoginCoordinator {
  func migrate(with migrationInfos: AccountMigrationInfos) {
    self.sessionServicesSubscription = SessionServicesContainer.buildSessionServices(
      from: migrationInfos.session,
      appServices: self.appServices,
      logger: sessionLogger,
      loadingContext: .remoteLogin()
    ) { [weak self] result in
      Task { @MainActor in
        guard let self = self else { return }

        switch result {
        case let .success(sessionServices):
          switch migrationInfos.type {
          case .ssoMemberToMpUser, .ssoMemberToAdmin:
            self.startSSO2MPMigrationFlow(
              with: migrationInfos,
              sessionServices: sessionServices
            )

          case .mpUserToSSOMember:
            self.startMP2SSOMigrationFlow(
              with: migrationInfos,
              sessionServices: sessionServices
            )

          case .undecodable:
            self.handle(error: UndecodableCaseError(SSOMigrationType.self))
          }

        case let .failure(error):
          self.handle(error: error)
        }
      }
    }
  }

  private func startMP2SSOMigrationFlow(
    with migrationInfos: AccountMigrationInfos,
    sessionServices: SessionServicesContainer
  ) {
    let viewModel = sessionServices.makeMP2SSOAccountMigrationViewModel(
      migrationInfos: migrationInfos
    ) { [weak self] result in
      self?.handle(result: result, logInfo: LoginFlowLogInfo(loginMode: .sso))
    }

    self.navigator.push(MP2SSOAccountMigrationFlow(viewModel: viewModel))
  }

  private func startSSO2MPMigrationFlow(
    with migrationInfos: AccountMigrationInfos,
    sessionServices: SessionServicesContainer
  ) {
    let viewModel = sessionServices.makeSSO2MPAccountMigrationViewModel(
      migrationInfos: migrationInfos
    ) { [weak self] result in
      self?.handle(result: result, logInfo: LoginFlowLogInfo(loginMode: .masterPassword))
    }

    self.navigator.push(SSO2MPAccoutMigrationFlow(viewModel: viewModel))
  }

  private func handle(result: AccountMigrationResult, logInfo: LoginFlowLogInfo) {
    switch result {
    case .success(let session):
      self.loadSessionServices(
        using: LocalLoginConfiguration(
          session: session,
          isFirstLogin: true,
          authenticationMode: nil
        ),
        logInfo: logInfo
      )

    case .cancel:
      self.completion(.logout)

    case .failure(let error):
      self.handle(error: error)
    }
  }
}
