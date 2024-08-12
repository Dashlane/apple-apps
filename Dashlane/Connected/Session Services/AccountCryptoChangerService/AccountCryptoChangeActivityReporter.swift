import CoreCrypto
import CoreSession
import CoreUserTracking
import DashTypes
import Foundation

struct AccountCryptoChangeActivityReporter {
  let activityReporter: ActivityReporterProtocol
  let type: Definition.CryptoMigrationType
  let newCrypto: Definition.CryptoAlgorithm
  let previousCrypto: Definition.CryptoAlgorithm

  init(
    type: Definition.CryptoMigrationType,
    migratingSession: MigratingSession,
    activityReporter: ActivityReporterProtocol
  ) {
    self.init(
      type: type,
      previousConfig: migratingSession.source.cryptoEngine.config,
      newConfig: migratingSession.target.cryptoConfig,
      activityReporter: activityReporter)
  }

  init(
    type: Definition.CryptoMigrationType,
    previousConfig: CryptoRawConfig,
    newConfig: CryptoRawConfig,
    activityReporter: ActivityReporterProtocol
  ) {
    self.type = type
    self.activityReporter = activityReporter
    self.previousCrypto = .make(cryptoConfig: previousConfig)
    self.newCrypto = .make(cryptoConfig: newConfig)
  }

  func report(_ result: AccountMigrationResult) {
    let status: Definition.CryptoMigrationStatus
    switch result {
    case .success:
      status = .success
    case let .failure(error):
      status = .init(error: error)
    }

    self.report(status)
  }

  func report(_ status: Definition.CryptoMigrationStatus) {
    activityReporter.report(
      UserEvent.MigrateCrypto(
        newCrypto: newCrypto,
        previousCrypto: previousCrypto,
        status: status,
        type: type))
  }
}

extension Definition.CryptoMigrationStatus {
  fileprivate init(error: AccountMigraterError) {
    switch error.step {
    case .downloading:
      self = .errorDownload
    case .reEncrypting:
      self = .errorReencryption
    case .uploading:
      self = .errorUpload
    case .delegateCompleting:
      self = .errorUpdateLocalData
    case .notifyingMasterKeyDone:
      self = .errorUpload
    }
  }
}

extension Definition.CryptoAlgorithm {
  fileprivate static func make(cryptoConfig: CryptoRawConfig) -> Definition.CryptoAlgorithm {
    guard let config = try? CryptoConfiguration(rawConfigMarker: cryptoConfig.marker) else {
      return .kwc3
    }

    return .init(config: config)
  }

  fileprivate init(config: CryptoConfiguration) {
    switch config {
    case .legacy(let legacy):
      switch legacy {
      case .kwc3:
        self = .kwc3
      case .kwc5:
        self = .kwc5
      }

    case .flexible(let flexible):
      switch flexible.derivation {
      case .argon2d:
        self = .argon2D
      case .pbkdf2:
        self = .pbkdf2
      case nil:
        self = .noDerivation
      }
    }
  }
}
