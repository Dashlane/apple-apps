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

  private let userDeviceAPI: UserDeviceAPIClient
  private let accessControl: AccessControlProtocol
  private let logger: Logger
  private var cancellables: Set<AnyCancellable> = []

  var currentContactEmail: String

  var onSaveAction: () -> Void

  let dismissActionPublisher = PassthroughSubject<Void, Never>()

  init(
    userDeviceAPI: UserDeviceAPIClient,
    accessControl: AccessControlProtocol,
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

  public func requestEmailChange(to newContactEmail: String, with toast: ToastAction) {
    accessControl
      .requestAccess(forReason: .changeContactEmail)
      .sink { [weak self] success in
        if success {
          self?.changeContactEmail(to: newContactEmail, with: toast)
        }
      }
      .store(in: &cancellables)
  }

  private func changeContactEmail(to newContactEmail: String, with toast: ToastAction) {
    Task {
      do {
        try await userDeviceAPI.account.updateContactInfo(contactEmail: newContactEmail)
        logger.debug("Successfully changed contact email")
        dismissActionPublisher.send()
        self.onSaveAction()
      } catch {
        logger.error("Failed to change contact email, error: \(error)")
        toast(L10n.Localizable.changeContactEmailErrorToast, image: .ds.feedback.fail.outlined)
      }
    }
  }
}

extension ChangeContactEmailViewModel {
  static var mock: ChangeContactEmailViewModel {
    ChangeContactEmailViewModel(
      userDeviceAPI: .fake,
      accessControl: FakeAccessControl(accept: true),
      logger: .mock,
      currentContactEmail: "",
      onSaveAction: {})
  }
}
