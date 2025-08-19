import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuSocialSecurityDetailView: View {

  @StateObject var model: ContextMenuSocialSecurityDetailViewModel

  init(model: @escaping @autoclosure () -> ContextMenuSocialSecurityDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if model.item.country?.name != nil {
          country
        }
        if !model.displayFullName.isEmpty {
          fullName
        }
        if !model.item.genderString.isEmpty {
          gender
        }
        if !model.item.number.isEmpty {
          socialSecurityNumber
        }
      }

      AutofillNotAvailableSection {
        if model.item.dateOfBirth != nil {
          birthDate
        }
      } shouldBeDisplayed: {
        model.item.dateOfBirth != nil
      }
    }
  }

  private var country: some View {
    DisplayField(
      CoreL10n.KWSocialSecurityStatementIOS.localeFormat, text: model.item.country?.name ?? ""
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.item.country?.name ?? "")
    }
  }

  private var fullName: some View {
    DisplayField(
      CoreL10n.KWSocialSecurityStatementIOS.socialSecurityFullname, text: model.displayFullName
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.displayFullName)
    }
  }

  private var gender: some View {
    DisplayField(CoreL10n.KWSocialSecurityStatementIOS.sex, text: model.item.genderString)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.genderString)
      }
  }

  private var birthDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWSocialSecurityStatementIOS.dateOfBirth,
        date: $model.item.dateOfBirth,
        range: .past)

      CopyButton(copy: model.service.copy, date: model.item.dateOfBirth)
    }
  }

  private var socialSecurityNumber: some View {
    DS.ObfuscatedDisplayField(
      CoreL10n.KWSocialSecurityStatementIOS.socialSecurityNumber, value: model.item.number,
      format: .obfuscated(maxLength: nil), actions: {}
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.item.number)
    }
  }
}

#Preview {
  ContextMenuSocialSecurityDetailView(model: .mock())
}
