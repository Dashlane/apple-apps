import Combine
import CoreNetworking
import CoreSession
import DashTypes
import DashlaneAPI
import DesignSystem
import Foundation
import VaultKit

@MainActor
class ChangeContactEmailViewModel: ObservableObject, SessionServicesInjecting {

  var currentContactEmail: String
  var onSaveAction: () -> Void

  private let accessControl: AccessControlHandler
  private let userDeviceAPI: UserDeviceAPIClient
  private let logger: Logger

  init(
    userDeviceAPI: UserDeviceAPIClient,
    accessControl: AccessControlHandler,
    logger: Logger,
    currentContactEmail: String,
    onSaveAction: @escaping () -> Void
  ) {
    self.userDeviceAPI = userDeviceAPI
    self.accessControl = accessControl
    self.logger = logger[.personalData]
    self.currentContactEmail = currentContactEmail
    self.onSaveAction = onSaveAction
  }

  public func changeContactEmail(to newContactEmail: String) async throws {
    do {
      try await accessControl.requestAccess(for: .changeContactEmail)
      try await userDeviceAPI.account.updateContactInfo(contactEmail: newContactEmail)
      logger.debug("Successfully changed contact email")
      self.onSaveAction()
    } catch is AccessControlError {
      logger.info("Access control denied")
    } catch {
      logger.error("Failed to change contact email, error: \(error)")
      throw error
    }
  }
}

extension ChangeContactEmailViewModel {
  static var mock: ChangeContactEmailViewModel {
    ChangeContactEmailViewModel(
      userDeviceAPI: .fake,
      accessControl: .mock(),
      logger: .mock,
      currentContactEmail: "",
      onSaveAction: {})
  }
}
