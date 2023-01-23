import Foundation
import DashTypes
import CoreSession
import SwiftTreats
import CoreKeychain
import DashlaneAppKit

struct LocalDataRemover {

    private let keychainService: AuthenticationKeychainServiceProtocol
    private let logger: Logger

            @SharedUserDefault(key: deleteLocalDataKey, default: false, userDefaults: .standard)
    public static var shouldDeleteLocalData: Bool
    private static let deleteLocalDataKey = "DELETE_LOCAL_DATA_NEXT_LAUNCH"

    init(keychainService: AuthenticationKeychainServiceProtocol,
         logger: Logger) {
        self.keychainService = keychainService
        self.logger = logger
    }

        func removeContainerData() {
        do {
                        let filesAndDirectories = try FileManager.default.contentsOfDirectory(atPath: ApplicationGroup.containerURL.path)
            try filesAndDirectories.forEach { name in
                let fileOrDirectoryPath = ApplicationGroup.containerURL.appendingPathComponent(name).path
                guard FileManager.default.isWritableFile(atPath: fileOrDirectoryPath) else { return }
                try FileManager.default.removeItem(atPath: fileOrDirectoryPath)
            }
            try keychainService.removeAllLocalData()
                        logger.fatal("Local data has been removed from the device.")
        } catch let KeychainError.unhandledError(status: status) {
            logger.fatal("Local data couldn't be removed from the device because of issue in Keychain \(status.description).")
            assertionFailure()
        } catch {
            logger.fatal("Local data couldn't be removed from the device.")
            assertionFailure()
        }

                disableShouldDeleteLocalData()
    }

    func disableShouldDeleteLocalData() {
        Self.shouldDeleteLocalData = false
    }
}

extension AppServicesContainer {
    func makeLocalDataRemover() -> LocalDataRemover {
        LocalDataRemover(keychainService: keychainService, logger: rootLogger)
    }
}
