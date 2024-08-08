import CorePersonalData
import Foundation
import SwiftUI

extension View {

  func makeShortcuts(model: CredentialDetailViewModel) -> some View {
    self
      .mainMenuShortcut(
        .copyPrimary(title: L10n.Localizable.copyPassword),
        enabled: !model.mode.isEditing && !model.item.password.isEmpty
          && model.item.metadata.sharingPermission != .limited,
        action: { model.copy(model.item.password, fieldType: .password) }
      )
      .mainMenuShortcut(
        .copySecondary(title: L10n.Localizable.copyEmail),
        enabled: !model.mode.isEditing && model.item.shouldEnableEmailShortcut,
        action: { model.copy(model.item.email, fieldType: .email) }
      )
      .mainMenuShortcut(
        .copySecondary(title: L10n.Localizable.copyLogin),
        enabled: !model.mode.isEditing && model.item.shouldEnableLoginShortcut,
        action: { model.copy(model.item.login, fieldType: .login) }
      )
      .mainMenuShortcut(
        .copySecondary(title: L10n.Localizable.copyLogin),
        enabled: !model.mode.isEditing && model.item.shouldEnableSecondaryLoginShortcut,
        action: { model.copy(model.item.secondaryLogin, fieldType: .secondaryLogin) })
  }
}

extension Credential {
  fileprivate var shouldEnableEmailShortcut: Bool {
    return !email.isEmpty
  }

  fileprivate var shouldEnableLoginShortcut: Bool {
    return !shouldEnableEmailShortcut && !login.isEmpty
  }

  fileprivate var shouldEnableSecondaryLoginShortcut: Bool {
    return !shouldEnableLoginShortcut && !secondaryLogin.isEmpty
  }
}
