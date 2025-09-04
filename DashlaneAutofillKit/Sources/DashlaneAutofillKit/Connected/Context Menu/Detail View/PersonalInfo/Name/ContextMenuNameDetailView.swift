import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuNameDetailView: View {

  @StateObject var model: ContextMenuNameDetailViewModel

  init(
    model: @escaping @autoclosure () -> ContextMenuNameDetailViewModel
  ) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if !model.item.personalTitle.id.isEmpty {
          title
        }
        if !model.item.firstName.isEmpty {
          firstName
        }
        if !model.item.middleName.isEmpty {
          middleName
        }
        if !model.item.lastName.isEmpty {
          lastName
        }
        if !model.item.pseudo.isEmpty {
          pseudo
        }
        if !model.item.birthPlace.isEmpty {
          birthPlace
        }
      }

      AutofillNotAvailableSection {
        if model.item.birthDate != nil {
          birthDate
        }
      } shouldBeDisplayed: {
        model.item.birthDate != nil
      }
    }
  }

  private var title: some View {
    DisplayField(CoreL10n.KWIdentityIOS.title, text: model.item.personalTitle.localizedString)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.personalTitle.localizedString)
      }
  }

  private var firstName: some View {
    DisplayField(CoreL10n.KWIdentityIOS.firstName, text: model.item.firstName)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.firstName)
      }
  }

  private var middleName: some View {
    DisplayField(CoreL10n.KWIdentityIOS.middleName, text: model.item.middleName)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.middleName)
      }
  }

  private var lastName: some View {
    DisplayField(CoreL10n.KWIdentityIOS.lastName, text: model.item.lastName)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.lastName)
      }
  }

  private var pseudo: some View {
    DisplayField(CoreL10n.KWIdentityIOS.pseudo, text: model.item.pseudo)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.pseudo)
      }
  }

  private var birthPlace: some View {
    DisplayField(CoreL10n.KWIdentityIOS.birthPlace, text: model.item.birthPlace)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.birthPlace)
      }
  }

  private var birthDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWIdentityIOS.birthDate,
        date: $model.item.birthDate,
        range: .past
      )
      .frame(width: .infinity, alignment: .leading)

      CopyButton(copy: model.service.copy, date: model.item.birthDate)
    }
  }
}

#Preview {
  ContextMenuNameDetailView(model: .mock())
}
