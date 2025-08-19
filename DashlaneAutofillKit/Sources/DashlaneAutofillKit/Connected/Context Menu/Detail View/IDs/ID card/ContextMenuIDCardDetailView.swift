import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuIDCardDetailView: View {

  @StateObject var model: ContextMenuIDCardDetailViewModel

  private var nationalityName: String {
    model.item.nationality?.name ?? CountryCodeNamePair.defaultCountry.name
  }

  init(model: @escaping @autoclosure () -> ContextMenuIDCardDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if !nationalityName.isEmpty {
          nationality
        }
        if !model.displayFullName.isEmpty {
          fullName
        }
        if !model.item.genderString.isEmpty {
          gender
        }
        if !model.item.number.isEmpty {
          cardNumber
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

  private var nationality: some View {
    DisplayField(CoreL10n.KWIDCardIOS.localeFormat, text: nationalityName)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: nationalityName)
      }
  }

  private var fullName: some View {
    DisplayField(CoreL10n.KWIDCardIOS.fullname, text: model.displayFullName)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.displayFullName)
      }
  }

  private var gender: some View {
    DisplayField(CoreL10n.KWIDCardIOS.sex, text: model.item.genderString)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.genderString)
      }
  }

  private var birthDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWIDCardIOS.dateOfBirth,
        date: $model.item.dateOfBirth,
        range: .past)

      CopyButton(copy: model.service.copy, date: model.item.dateOfBirth)
    }
  }

  private var cardNumber: some View {
    DisplayField(CoreL10n.KWIDCardIOS.number, text: model.item.number)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.number)
      }
  }

  private var issueDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWIDCardIOS.deliveryDate,
        date: $model.item.deliveryDate,
        range: .past)

      CopyButton(copy: model.service.copy, date: model.item.deliveryDate)
    }
  }

  private var expirationDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWIDCardIOS.expireDate,
        date: $model.item.expireDate,
        range: .future)

      CopyButton(copy: model.service.copy, date: model.item.expireDate)
    }
  }
}

#Preview {
  ContextMenuIDCardDetailView(model: .mock())
}
