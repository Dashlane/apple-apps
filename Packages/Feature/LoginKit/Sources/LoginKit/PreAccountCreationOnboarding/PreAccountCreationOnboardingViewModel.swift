import CoreFeature
import CoreKeychain
import CoreSession
import CoreSettings
import CoreTypes
import CoreUserTracking
import Foundation
import LogFoundation
import SwiftTreats
import UserTrackingFoundation

public class PreAccountCreationOnboardingViewModel {
  public enum NextStep {
    case accountCreation
    case login
  }

  @SharedUserDefault(key: deleteLocalDataKey, default: false, userDefaults: .standard)
  public static var shouldDeleteLocalData: Bool
  private static let deleteLocalDataKey = "DELETE_LOCAL_DATA_NEXT_LAUNCH"

  let keychainService: AuthenticationKeychainServiceProtocol
  let logger: Logger
  let analyticsInstallationId: LowercasedUUID
  let completion: ((NextStep) -> Void)

  public init(
    keychainService: AuthenticationKeychainServiceProtocol,
    logger: Logger,
    completion: @escaping ((NextStep) -> Void)
  ) {
    self.keychainService = keychainService
    self.logger = logger
    self.completion = completion
    self.analyticsInstallationId = DefaultAnalyticsId.analyticsInstallationId
  }

  func showLogin() {
    completion(.login)
  }

  func showAccountCreation() {
    completion(.accountCreation)
  }

  var shouldDeleteLocalData: Bool {
    PreAccountCreationOnboardingViewModel.shouldDeleteLocalData
  }

  func disableShouldDeleteLocalDataSetting() {
    disableShouldDeleteLocalData()
  }

  func deleteAllLocalData() {
    removeContainerData()
  }

  func removeContainerData() {
    do {
      let filesAndDirectories = try FileManager.default.contentsOfDirectory(
        atPath: ApplicationGroup.containerURL.path)
      try filesAndDirectories.forEach { name in
        let fileOrDirectoryPath = ApplicationGroup.containerURL.appendingPathComponent(name).path
        guard FileManager.default.isWritableFile(atPath: fileOrDirectoryPath) else { return }
        try FileManager.default.removeItem(atPath: fileOrDirectoryPath)
      }
      try keychainService.removeAllLocalData()

      logger.info("Local data has been removed from the device.")
    } catch let KeychainError.unhandledError(status: status) {
      logger.fatal(
        "Local data couldn't be removed from the device because of issue in Keychain \(status.description, privacy: .public)."
      )
      assertionFailure()
    } catch {
      logger.fatal("Local data couldn't be removed from the device.")
      assertionFailure()
    }

    disableShouldDeleteLocalData()
  }

  public func disableShouldDeleteLocalData() {
    Self.shouldDeleteLocalData = false
  }
}
