import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuCreditCardDetailView: View {

  @StateObject var model: ContextMenuCreditCardDetailViewModel

  init(model: @escaping @autoclosure () -> ContextMenuCreditCardDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if model.item.country != nil {
          country
        }
        if !model.item.ownerName.isEmpty {
          cardholderName
        }
        if !model.item.cardNumber.isEmpty {
          cardNumber
        }
        if !model.item.securityCode.isEmpty {
          securityCode
        }
        if !model.item.note.isEmpty {
          note
        }
        if model.item.bank != nil {
          bank
        }
      }
      AutofillNotAvailableSection {
        if model.item.expiryDate != nil {
          expirationDate
        }
      } shouldBeDisplayed: {
        model.item.expiryDate != nil
      }
    }
  }

  private var country: some View {
    DisplayField(
      CoreL10n.KWPaymentMeanCreditCardIOS.localeFormat, text: model.item.country?.name ?? ""
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.item.country?.name ?? "")
    }
  }

  private var cardholderName: some View {
    DisplayField(CoreL10n.KWPaymentMeanCreditCardIOS.ownerName, text: model.item.ownerName)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.ownerName)
      }
  }

  private var cardNumber: some View {
    DS.ObfuscatedDisplayField(
      CoreL10n.KWPaymentMeanCreditCardIOS.cardNumber, value: model.item.cardNumber,
      format: .cardNumber, actions: {}
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.item.cardNumber)
    }
  }

  private var securityCode: some View {
    DS.ObfuscatedDisplayField(
      CoreL10n.KWPaymentMeanCreditCardIOS.securityCode, value: model.item.securityCode,
      format: .obfuscated(maxLength: nil), actions: {}
    )
    .contentShape(Rectangle())
    .onTapGesture {
      model.performAutofill(with: model.item.securityCode)
    }
  }

  private var note: some View {
    DisplayField(CoreL10n.KWPaymentMeanCreditCardIOS.ccNote, text: model.item.note)
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.note)
      }
  }

  private var bank: some View {
    DisplayField(CoreL10n.KWPaymentMeanCreditCardIOS.bank, text: model.item.bank?.name ?? "")
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.bank?.name ?? "")
      }
  }

  private var expirationDate: some View {
    HStack {
      DateDetailField(
        title: CoreL10n.KWPaymentMeanCreditCardIOS.expiryDateForUi,
        date: $model.item.editableExpireDate,
        range: .future
      )
      .dateFieldStyle(.monthYear)

      CopyButton(copy: model.service.copy, date: model.item.expiryDate, formatter: .monthAndYear)
    }
  }
}

#Preview {
  ContextMenuCreditCardDetailView(model: .mock())
}
