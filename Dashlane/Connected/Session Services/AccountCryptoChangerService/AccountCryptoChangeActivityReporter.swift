import Foundation
import CoreSession
import CoreUserTracking
import DashlaneCrypto
import DashlaneAppKit
import DashTypes

struct AccountCryptoChangeActivityReporter {
    let activityReporter: ActivityReporterProtocol
    let type: Definition.CryptoMigrationType
    let newCrypto: Definition.CryptoAlgorithm
    let previousCrypto: Definition.CryptoAlgorithm

    init(type: Definition.CryptoMigrationType,
         migratingSession: MigratingSession,
         activityReporter: ActivityReporterProtocol) {
        self.init(type: type,
                  previousConfig: migratingSession.source.cryptoEngine.config,
                  newConfig: migratingSession.target.cryptoConfig,
                  activityReporter: activityReporter)
    }

    init(type: Definition.CryptoMigrationType,
         previousConfig: CryptoRawConfig,
         newConfig: CryptoRawConfig,
         activityReporter: ActivityReporterProtocol) {
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
        activityReporter.report(UserEvent.MigrateCrypto(newCrypto: newCrypto,
                                                        previousCrypto: previousCrypto,
                                                        status: status,
                                                        type: type))
    }
}

private extension Definition.CryptoMigrationStatus {
    init(error: AccountMigraterError) {
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

private extension Definition.CryptoAlgorithm {
    static func make(cryptoConfig: CryptoRawConfig) -> Definition.CryptoAlgorithm {
        guard let config = CryptoConfigParser.configuration(from: cryptoConfig.parametersHeader) else {
            return .kwc3
        }

        return .init(config: config)
    }

    init(config: CryptoConfig) {
        switch config {
            case .kwc3:
                self = .kwc3
            case .kwc5:
                self = .kwc5
            case .argon2dBased:
                self = .argon2D
            case .pbkdf2Based:
                self = .pbkdf2
            case .noDerivation:
                self = .noDerivation
        }
    }
}
