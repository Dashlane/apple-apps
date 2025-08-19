import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuPassportDetailView: View {

  @StateObject var model: ContextMenuPassportDetailViewModel

  init(model: @escaping @autoclosure () -> ContextMenuPassportDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if model.selectedCountry != nil {
          country
        }
        if !model.displayFullName.isEmpty {
          fullName
        }
        if !model.item.genderString.isEmpty {
          gender
        }
        if !model.item.number.isEmpty {
          passportNumber
        }
        if !model.item.deliveryPlace.isEmpty {
          deliveryPlace
        }
      }

      AutofillNotAvailableSection {
        if model.item.dateOfBirth != nil {
          birthDate
        }
        if model.item.deliveryDate != nil {
          issueDate
        }
        if model.item.expireDate != nil {
          expirationDate
        }
      } shouldBeDisplayed: {
        model.item.dateOfBirth != nil || model.item.deliveryDate != nil
          || model.item.expireDate != nil
      }
    }
  }

  private var country: some View {
    DisplayField(CoreL10n.KWPassportIOS.localeFormat, text: model.selectedCountry?.name ?? "")
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.selectedCountry?.name ?? "")
      }
  }

  private var fullName: some View {
    DisplayField(CoreL10n.KWPassportIOS.fullname, text: model.displayFullName)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.displayFullName)
      }
  }

  private var gender: some View {
    DisplayField(CoreL10n.KWDriverLicenceIOS.sex, text: model.item.genderString)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.genderString)
      }
  }

  private var birthDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWPassportIOS.dateOfBirth,
        date: $model.item.dateOfBirth,
        range: .past)

      CopyButton(copy: model.service.copy, date: model.item.dateOfBirth)
    }
  }

  private var passportNumber: some View {
    DisplayField(CoreL10n.KWPassportIOS.number, text: model.item.number)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.number)
      }
  }

  private var deliveryPlace: some View {
    DisplayField(CoreL10n.KWPassportIOS.deliveryPlace, text: model.item.deliveryPlace)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.deliveryPlace)
      }
  }

  private var issueDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWPassportIOS.deliveryDate,
        date: $model.item.deliveryDate,
        range: .past)

      CopyButton(copy: model.service.copy, date: model.item.deliveryDate)
    }
  }

  private var expirationDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWPassportIOS.expireDate,
        date: $model.item.expireDate,
        range: .future)

      CopyButton(copy: model.service.copy, date: model.item.expireDate)
    }
  }
}

#Preview {
  ContextMenuPassportDetailView(model: .mock())
}
