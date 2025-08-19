import CoreLocalization
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuCredentialDetailView: View {

  @StateObject var model: ContextMenuCredentialDetailViewModel

  init(model: @escaping @autoclosure () -> ContextMenuCredentialDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      Section {
        DS.Infobox(CoreL10n.contextMenuAutofillTrustThisWebsite)
          .style(mood: .warning)
      }
      .listSectionSpacing(0)

      AutofillAvailableSection(mood: .neutral) {
        if !model.item.email.isEmpty {
          emailField
        }
        if !model.item.login.isEmpty {
          usernameField
        }
        if !model.item.secondaryLogin.isEmpty {
          alternateUsernameField
        }
        if !model.item.password.isEmpty {
          passwordField
        }
        if model.item.otpConfiguration != nil {
          totpField
        }
        if model.item.url != nil {
          websiteField
        }
      }
    }
    .contentMargins(.top, 0)
  }

  private var emailField: some View {
    DisplayField(CoreL10n.KWAuthentifiantIOS.email, text: model.item.email)
      .fiberFieldType(.email)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.email)
      }
  }

  private var usernameField: some View {
    DisplayField(CoreL10n.KWAuthentifiantIOS.login, text: model.item.login)
      .fiberFieldType(.login)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.login)
      }
  }

  private var alternateUsernameField: some View {
    DisplayField(CoreL10n.KWAuthentifiantIOS.secondaryLogin, text: model.item.secondaryLogin)
      .fiberFieldType(.secondaryLogin)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.secondaryLogin)
      }
  }

  private var passwordField: some View {
    DS.PasswordDisplayField(
      CoreL10n.KWAuthentifiantIOS.password,
      password: model.item.password
    )
    .fiberFieldType(.password)
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.item.password)
    }
    .limitedRightsAutofill(model: .init(item: model.item, isFrozen: false))
  }

  private var totpField: some View {
    TOTPDetailField(
      otpURL: $model.item.otpURL,
      shouldPresent2FASetupFlow: .constant(false),
      actions: [], didChange: {}
    )
    .fiberFieldType(.otp)
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.totpCode ?? "")
    }
  }

  private var websiteField: some View {
    DisplayField(CoreL10n.KWAuthentifiantIOS.urlStringForUI, text: model.item.url?.rawValue ?? "")
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.url?.rawValue ?? "")
      }
  }
}

#Preview {
  ContextMenuCredentialDetailView(model: .mock())
}
