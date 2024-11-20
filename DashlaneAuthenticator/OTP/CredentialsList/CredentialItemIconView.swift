import Combine
import CorePersonalData
import Foundation
import IconLibrary
import SwiftUI
import VaultKit

struct CredentialItemIconView: View {
  let model: VaultItemIconViewModel

  init(model: @autoclosure () -> (VaultItemIconViewModel)) {
    self.model = model()
  }

  @ViewBuilder
  var body: some View {
    switch model.item.icon(forListStyle: true) {
    case .credential(let credential):
      DomainIconView(model: model.makeDomainIconViewModel(credential: credential))

    default:
      fatalError("Should not try to show credit cards")
    }
  }
}

extension CredentialItemIconView: Equatable {
  static func == (lhs: CredentialItemIconView, rhs: CredentialItemIconView) -> Bool {
    return lhs.model.item.icon == rhs.model.item.icon
  }
}

extension VaultItem {
  func icon(forListStyle isListStyle: Bool) -> VaultItemIcon {
    return isListStyle ? listIcon : icon
  }
}
