import CoreKeychain
import CoreSession
import DashTypes
import Foundation
import UIDelight

public class DebugAccountListViewModel: ObservableObject, LoginKitServicesInjecting {
  let sessionCleaner: SessionCleaner
  let sessionsContainer: SessionsContainerProtocol

  @Published
  var localAccounts: [AccountInfo] = []

  @Published
  var testAccounts: [AccountInfo] = []

  public init(
    sessionCleaner: SessionCleaner,
    sessionsContainer: SessionsContainerProtocol
  ) {
    self.sessionCleaner = sessionCleaner
    self.sessionsContainer = sessionsContainer
  }

  func fetchLocalAccounts() {
    self.localAccounts = (try? sessionsContainer.localAccounts()) ?? []
    self.testAccounts = TestAccountInfo.testAccounts.filter { account in
      !localAccounts.map(\.email).contains(account.email)
    }
  }

  func removeLocalData(for login: Login) {
    sessionCleaner.removeLocalData(for: login)
    fetchLocalAccounts()
  }
}

extension DebugAccountListViewModel {
  static var mock: DebugAccountListViewModel {
    .init(
      sessionCleaner: .init(
        keychainService: .fake,
        sessionsContainer: FakeSessionsContainer(),
        logger: LoggerMock()),
      sessionsContainer: FakeSessionsContainer())
  }
}
