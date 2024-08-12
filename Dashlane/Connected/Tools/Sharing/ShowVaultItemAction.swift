import Foundation
import SwiftUI
import VaultKit

struct ShowVaultItemAction {
  let action: (_ item: VaultItem) -> Void

  func callAsFunction(_ item: VaultItem) {
    action(item)
  }
}

struct ShowVaultItemActionKey: EnvironmentKey {
  static var defaultValue: ShowVaultItemAction = .init { _ in }
}

extension EnvironmentValues {
  var showVaultItem: ShowVaultItemAction {
    get { self[ShowVaultItemActionKey.self] }
    set { self[ShowVaultItemActionKey.self] = newValue }
  }
}
