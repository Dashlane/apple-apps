import Combine
import CoreNetworking
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import VaultKit

class AccountSummaryViewModel: ObservableObject, SessionServicesInjecting {
  let session: Session
  private let userDeviceAPI: UserDeviceAPIClient
  private var cancellables: Set<AnyCancellable> = []
  let changeContactEmailViewModelFactory: ChangeContactEmailViewModel.Factory

  @Published
  var contactEmail: String = ""

  init(
    session: Session,
    userDeviceAPI: UserDeviceAPIClient,
    accessControl: AccessControlHandler,
    changeContactEmailViewModelFactory: ChangeContactEmailViewModel.Factory
  ) {
    self.session = session
    self.userDeviceAPI = userDeviceAPI
    self.changeContactEmailViewModelFactory = changeContactEmailViewModelFactory
  }

  @MainActor
  public func fetchContactEmail() async {
    do {
      let accountInfo = try await userDeviceAPI.account.accountInfo()
      self.contactEmail = accountInfo.contactEmail ?? self.session.login.email
    } catch {
      self.contactEmail = self.session.login.email
    }
  }

}

extension AccountSummaryViewModel {
  static var mock: AccountSummaryViewModel {
    AccountSummaryViewModel(
      session: .mock,
      userDeviceAPI: .fake,
      accessControl: .mock(),
      changeContactEmailViewModelFactory: .init({ _, _ in .mock }))
  }
}
