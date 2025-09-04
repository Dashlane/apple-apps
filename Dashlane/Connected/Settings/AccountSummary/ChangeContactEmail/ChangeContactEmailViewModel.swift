import Combine
import CoreNetworking
import CoreSession
import CoreTypes
import DashlaneAPI
import DesignSystem
import Foundation
import LogFoundation
import VaultKit

@MainActor
class ChangeContactEmailViewModel: ObservableObject, SessionServicesInjecting {

  var currentContactEmail: String
  var onSaveAction: () -> Void

  private let userDeviceAPI: UserDeviceAPIClient
  private let logger: Logger

  init(
    userDeviceAPI: UserDeviceAPIClient,
    logger: Logger,
    currentContactEmail: String,
    onSaveAction: @escaping () -> Void
  ) {
    self.userDeviceAPI = userDeviceAPI
    self.logger = logger[.personalData]
    self.currentContactEmail = currentContactEmail
    self.onSaveAction = onSaveAction
  }

  public func changeContactEmail(to newContactEmail: String) async throws {
    do {
      try await userDeviceAPI.account.updateContactInfo(contactEmail: newContactEmail)
      logger.debug("Successfully changed contact email")
      self.onSaveAction()
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
      logger: .mock,
      currentContactEmail: "",
      onSaveAction: {})
  }
}
