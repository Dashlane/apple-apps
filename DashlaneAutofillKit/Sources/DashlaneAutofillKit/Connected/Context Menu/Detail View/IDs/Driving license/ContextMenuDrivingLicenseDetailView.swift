import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuDrivingLicenseDetailView: View {

  @StateObject var model: ContextMenuDrivingLicenseDetailViewModel

  init(model: @escaping @autoclosure () -> ContextMenuDrivingLicenseDetailViewModel) {
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
          number
        }
        if model.item.state?.name != nil {
          state
        }
      }

      AutofillNotAvailableSection {
        if model.item.deliveryDate != nil {
          issueDate
        }
        if model.item.expireDate != nil {
          expirationDate
        }
      } shouldBeDisplayed: {
        model.item.deliveryDate != nil || model.item.expireDate != nil
      }
    }
  }

  private var country: some View {
    DisplayField(CoreL10n.KWDriverLicenceIOS.localeFormat, text: model.item.country?.name ?? "")
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.country?.name ?? "")
      }
  }

  private var fullName: some View {
    DisplayField(CoreL10n.KWDriverLicenceIOS.fullname, text: model.displayFullName)
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

  private var number: some View {
    DisplayField(CoreL10n.KWDriverLicenceIOS.number, text: model.item.number)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.number)
      }
  }

  private var state: some View {
    DisplayField(CoreL10n.KWDriverLicenceIOS.state, text: model.item.state?.name ?? "")
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.state?.name ?? "")
      }
  }

  private var issueDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWIDCardIOS.deliveryDate,
        date: $model.item.deliveryDate,
        range: .past
      )
      .contentShape(Rectangle())

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
  ContextMenuDrivingLicenseDetailView(model: .mock())
}
