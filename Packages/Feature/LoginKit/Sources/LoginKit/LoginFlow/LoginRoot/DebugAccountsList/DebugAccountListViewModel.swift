import CoreKeychain
import CoreSession
import CoreTypes
import Foundation
import UIDelight

public class DebugAccountListViewModel: ObservableObject, LoginKitServicesInjecting {
  let sessionCleaner: SessionCleanerProtocol
  let sessionsContainer: SessionsContainerProtocol

  @Published
  var localAccounts: [AccountInfo] = []

  @Published
  var testAccounts: [AccountInfo] = []

  public init(
    sessionCleaner: SessionCleanerProtocol,
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
      sessionCleaner: .mock,
      sessionsContainer: .mock)
  }
}
